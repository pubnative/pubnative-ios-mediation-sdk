//
//  PNConfigManager.m
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNConfigManager.h"
#import "PNConfigAPIResponseModel.h"
#import "PNConfigRequestModel.h"
#import "PNHttpRequest.h"
#import "PNReachability.h"
#import "PNSettings.h"
#import "PubnativeLibraryCPICache.h"

NSString * const kPNDefaultConfigURL     = @"https://ml.pubnative.net/ml/v1/config";

NSString * const kPNAppTokenURLParameter         = @"app_token";
NSString * const kPNOSVersionURLParameter        = @"os_version";
NSString * const kPNConnectionTypeURLParameter   = @"connection_type";
NSString * const kPNDeviceNameURLParameter       = @"device_name";
NSString * const kPNConnectionTypeWifi           = @"wifi";
NSString * const kPNConnectionTypeCellular       = @"cellular";

NSString * const kPNConfigKey            = @"PNConfigManager.configJSON";
NSString * const kPNAppTokenKey          = @"PNConfigManager.configAppToken";
NSString * const kPNTimestampKey         = @"PNConfigManager.configTimestamp";

@interface PNConfigManager () <NSURLConnectionDataDelegate>

@property (nonatomic, strong)NSDictionary               *configExtras;
@property (nonatomic, strong)NSMutableArray             *requestQueue;
@property (nonatomic, strong)PNConfigRequestModel       *currentRequest;
@property (nonatomic, assign)BOOL                       idle;

@property (nonatomic, readonly)NSString                 *configBaseURL;
@property (nonatomic, readonly)NSString                 *configRequestURL;
@property (nonatomic, readonly)NSTimeInterval           storedTimestamp;
@property (nonatomic, readonly)NSString                 *storedAppToken;
@property (nonatomic, readonly)PNConfigModel         *storedConfig;

@end

@implementation PNConfigManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:[PNConfigManager sharedInstance]];
    
    self.configExtras = nil;
    self.requestQueue = nil;
    self.currentRequest = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idle = YES;
        
        [[PNSettings sharedInstance] fillDefaults];
        NSMutableDictionary *extras = [NSMutableDictionary dictionary];
        extras[kPNDeviceNameURLParameter] = [PNSettings sharedInstance].deviceName;
        extras[kPNOSVersionURLParameter] = [PNSettings sharedInstance].osVersion;
        PNReachability *reachability = [PNReachability reachabilityForInternetConnection];
        [reachability startNotifier];
        if(PNNetworkStatus_ReachableViaWiFi == reachability.currentReachabilityStatus) {
            extras[kPNConnectionTypeURLParameter] = kPNConnectionTypeWifi;
        } else {
            extras[kPNConnectionTypeURLParameter] = kPNConnectionTypeCellular;
        }
        [reachability stopNotifier];
        self.configExtras = extras;
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    
    static PNConfigManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PNConfigManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)reset
{
    [[PNConfigManager sharedInstance] setStoredConfig:nil];
    [[PNConfigManager sharedInstance] setStoredAppToken:nil];
    [[PNConfigManager sharedInstance] setStoredTimestamp:0];
}

+ (void)configWithAppToken:(NSString*)appToken
                    extras:(NSDictionary*)extras
                  delegate:(NSObject<PNConfigManagerDelegate>*)delegate
{
    if (delegate == nil) {
        NSLog(@"PNConfigManager - delegate not specified, are you sure?");
    }
    
    if (appToken == nil || appToken.length == 0) {
        NSLog(@"PNConfigManager - invalid app token");
        [[PNConfigManager sharedInstance] invokeDidFinishWithModel:nil
                                                          delegate:delegate];
    } else {
        PNConfigRequestModel *requestModel = [[PNConfigRequestModel alloc] init];
        requestModel.appToken = appToken;
        requestModel.extras = extras;
        requestModel.delegate = delegate;
        [[PNConfigManager sharedInstance] enqueueRequestModel:requestModel];
        [[PNConfigManager sharedInstance] doNextRequest];
    }
}

- (void)doNextRequest
{
    if ([PNConfigManager sharedInstance].idle) {
        PNConfigRequestModel *requestModel = [self dequeueRequestDelegate];
        if(requestModel){
            self.idle = NO;
            self.currentRequest = requestModel;
            [self getNextConfig];
        }
    }
}

- (void)getNextConfig
{
    if([self storedConfigNeedsUpdateWithAppToken:self.currentRequest.appToken]){
        // re-fill when re-downloading the cache
        [[PNSettings sharedInstance] fillDefaults];
        [self downloadConfig];
    } else {
        // Serve stored config
        [self serveStoredConfig];
    }
}

- (BOOL)storedConfigNeedsUpdateWithAppToken:(NSString*)appToken
{
    BOOL result = YES;
    
    PNConfigModel *storedModel = self.storedConfig;
    NSTimeInterval storedTimestamp = self.storedTimestamp;
    
    if([self.storedAppToken isEqualToString:appToken] && storedModel && storedTimestamp){
        NSNumber *refreshInMinutes = (NSNumber*) [storedModel.globals objectForKey:PN_CONFIG_GLOBAL_KEY_REFRESH];
        
        if(refreshInMinutes && refreshInMinutes > 0) {
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval elapsedTime = currentTimestamp - storedTimestamp;
            NSTimeInterval refreshSeconds = [refreshInMinutes intValue] * 60;
            
            if(elapsedTime < refreshSeconds){
                // Config still valid
                result = NO;
            }
        }
    }
    
    return result;
}

- (void)downloadConfig
{
    __weak PNConfigManager *weakSelf = self;
    [PNHttpRequest requestWithURL:self.configRequestURL
                andCompletionHandler:^(NSString *result, NSError *error) {
                    if (error) {
                        [weakSelf invokeDidFinishWithModel:nil delegate:weakSelf.currentRequest.delegate];
                    } else {
                        
                        NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *dataError;
                        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                       options:NSJSONReadingMutableContainers
                                                                                         error:&dataError];
                        if (dataError) {
                            NSLog(@"PNConfigManager - data error: %@", dataError);
                            [weakSelf invokeDidFinishWithModel:nil delegate:weakSelf.currentRequest.delegate];
                        } else {
                            PNConfigAPIResponseModel *apiResponse = [PNConfigAPIResponseModel modelWithDictionary:jsonDictionary];
                            
                            if (apiResponse) {
                                
                                if ([apiResponse isSuccess]) {
                                    
                                    [weakSelf processDownloadedConfig:apiResponse.config
                                                         withAppToken:weakSelf.currentRequest.appToken];
                                    [weakSelf serveStoredConfig];
                                    
                                } else {
                                    
                                    NSLog(@"PNConfigManager - server error: %@", apiResponse.error_message);
                                    [weakSelf invokeDidFinishWithModel:nil delegate:weakSelf.currentRequest.delegate];
                                }
                                
                            } else {
                                
                                NSLog(@"PNConfigManager - parsing error");
                                [weakSelf invokeDidFinishWithModel:nil delegate:weakSelf.currentRequest.delegate];
                            }
                        }
                    }
                }];
}

- (void)serveStoredConfig
{
    PNConfigModel *storedConfig = [self storedConfig];
    
    // Ensure that the CPICache is fill before allowing any request
    [[NSNotificationCenter defaultCenter] removeObserver:[PNConfigManager sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:[PNConfigManager sharedInstance]
                                             selector:@selector(cpiCacheDidFinishLoading:)
                                                 name:kCPICacheDidFinishLoadingNotification
                                               object:nil];
    
    [PubnativeLibraryCPICache initWithAppToken:self.currentRequest.appToken config:storedConfig];
    
}

- (void)cpiCacheDidFinishLoading:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:[PNConfigManager sharedInstance]];
    [self invokeDidFinishWithModel:self.storedConfig
                          delegate:self.currentRequest.delegate];
}

#pragma mark - QUEUE -

- (void)enqueueRequestModel:(PNConfigRequestModel*)request
{
    if(request
       && request.appToken && [request.appToken length] > 0)
    {
        if(!self.requestQueue){
            self.requestQueue = [[NSMutableArray alloc] init];
        }
        [self.requestQueue addObject:request];
    }
}

- (PNConfigRequestModel*)dequeueRequestDelegate
{
    PNConfigRequestModel *result = nil;
    
    if(self.requestQueue &&
       [self.requestQueue count] > 0){
        
        result = [self.requestQueue objectAtIndex:0];
        [self.requestQueue removeObjectAtIndex:0];
    }
    return result;
}

#pragma mark - DOWNLOAD -

- (NSString*)configBaseURL
{
    NSString *result = kPNDefaultConfigURL;
    PNConfigModel *storedConfig = [self storedConfig];
    if(storedConfig && !storedConfig.isEmpty){
        result = (NSString*)storedConfig.globals[PN_CONFIG_GLOBAL_KEY_CONFIG_URL];
    }
    return result;
}

- (NSString*)configRequestURL
{
    NSString *result = self.configBaseURL;
    result = [NSString stringWithFormat:@"%@?%@=%@", result, kPNAppTokenURLParameter, self.currentRequest.appToken];
    result = [self addQueryStringWithUrl:result dictionary:self.configExtras];
    result = [self addQueryStringWithUrl:result dictionary:self.currentRequest.extras];
    return result;
}

- (NSString*)addQueryStringWithUrl:(NSString*)url dictionary:(NSDictionary*)parameters
{
    NSString *result = url;
    if(parameters) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            result = [self addQueryStringWithUrl:result key:key value:value];
        }
    }
    return result;
}

- (NSString*)addQueryStringWithUrl:(NSString*)url key:(NSString*)key value:(NSString*)value
{
    NSString *result = url;
    if(key && key.length > 0 && value && value.length > 0) {
        result = [NSString stringWithFormat:@"%@&%@=%@", result, key, value];
    }
    return result;
}

- (void)processDownloadedConfig:(PNConfigModel*)newConfig
                   withAppToken:(NSString*)appToken
{
    if (appToken || appToken.length > 0 || newConfig || !newConfig.isEmpty) {
        
        [self updateStoredConfig:newConfig
                    withAppToken:appToken];
    } else {
        
        NSLog(@"PNConfigManager - Error: ");
    }
}

- (void)updateStoredConfig:(PNConfigModel*)model
              withAppToken:(NSString*)appToken
{
    if(appToken && [appToken length] > 0 &&
       model && !model.isEmpty){
        self.storedConfig = model;
        self.storedAppToken = appToken;
        self.storedTimestamp = [[NSDate date] timeIntervalSince1970];
    }
}

#pragma mark Callback helpers

- (void)invokeDidFinishWithModel:(PNConfigModel*)model
                        delegate:(NSObject<PNConfigManagerDelegate>*)delegate
{
    if(delegate && [delegate respondsToSelector:@selector(configDidFinishWithModel:)]){
        [delegate configDidFinishWithModel:model];
    }
    self.idle = YES;
    [self doNextRequest];
}

#pragma mark - NSUserDefaults -

#pragma mark Timestamp

- (void)setStoredTimestamp:(NSTimeInterval)timestamp
{
    if(timestamp > 0){
        [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:kPNTimestampKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPNTimestampKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)storedTimestamp
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPNTimestampKey];
}

#pragma mark AppToken

-(void)setStoredAppToken:(NSString *)appToken
{
    if(appToken && [appToken length] > 0){
        [[NSUserDefaults standardUserDefaults] setObject:appToken forKey:kPNAppTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPNAppTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)storedAppToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPNAppTokenKey];
}

#pragma mark Config

-(void)setStoredConfig:(PNConfigModel *)config
{
    if(config && !config.isEmpty) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[config toDictionary]
                                                           options:0
                                                             error:&parseError];
        if(parseError) {
            NSLog(@"PNConfigManager - cannot store config, parse error: %@", parseError);
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:kPNConfigKey];
        }
    
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPNConfigKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(PNConfigModel *)storedConfig
{
    PNConfigModel *result;
    
    NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:kPNConfigKey];
    
    if(jsonData){
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        result = [PNConfigModel modelWithDictionary:jsonDictionary];
    }
    return result;
}

@end
