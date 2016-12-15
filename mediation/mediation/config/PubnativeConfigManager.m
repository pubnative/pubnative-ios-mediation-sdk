//
//  PubnativeConfigManager.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigManager.h"
#import "PubnativeConfigAPIResponseModel.h"
#import "PubnativeConfigRequestModel.h"
#import "PubnativeHttpRequest.h"
#import "PubnativeDeliveryManager.h"

static PubnativeConfigManager* _sharedInstance;

NSString * const kDefaultConfigURL                  = @"https://ml.pubnative.net/ml/v1/config";
NSString * const kAppTokenURLParameter              = @"app_token";

NSString * const kUserDefaultsStoredConfigKey       = @"net.pubnative.mediation.PubnativeConfigManager.configJSON";
NSString * const kUserDefaultsStoredAppTokenKey     = @"net.pubnative.mediation.PubnativeConfigManager.configAppToken";
NSString * const kUserDefaultsStoredTimestampKey    = @"net.pubnative.mediation.PubnativeConfigManager.configTimestamp";

@interface PubnativeConfigManager () <NSURLConnectionDataDelegate>

@property (nonatomic, strong)NSMutableArray *requestQueue;
@property (nonatomic, assign)BOOL           idle;

@end

@implementation PubnativeConfigManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idle = YES;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static PubnativeConfigManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PubnativeConfigManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)reset
{
    [PubnativeConfigManager setStoredConfig:nil];
    [PubnativeConfigManager setStoredAppToken:nil];
    [PubnativeConfigManager setStoredTimestamp:0];
}

+ (void)configWithAppToken:(NSString*)appToken
                    extras:(NSDictionary<NSString*, NSString*>*)extras
                  delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate
{
    // Drop the call if no completion handler specified
    if (delegate){
        if (appToken && [appToken length] > 0){
            PubnativeConfigRequestModel *requestModel = [[PubnativeConfigRequestModel alloc] init];
            requestModel.appToken = appToken;
            requestModel.extras = extras;
            requestModel.delegate = delegate;
            [PubnativeConfigManager enqueueRequestModel:requestModel];
            [PubnativeConfigManager doNextRequest];
        } else {
            NSLog(@"PubnativeConfigManager - invalid app token");
            [PubnativeConfigManager invokeDidFinishWithModel:nil
                                                    delegate:delegate];
        }
    } else {
        NSLog(@"PubnativeConfigManager - delegate not specified, dropping the call");
    }
}

+ (void)doNextRequest
{
    if([PubnativeConfigManager sharedInstance].idle){
        PubnativeConfigRequestModel *requestModel = [PubnativeConfigManager dequeueRequestDelegate];
        if(requestModel){
            [PubnativeConfigManager sharedInstance].idle = NO;
            [PubnativeConfigManager getNextConfigWithModel:requestModel];
        }
    }
}

+ (void)getNextConfigWithModel:(PubnativeConfigRequestModel*)requestModel
{
    if([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestModel.appToken]){
        // Download
        [PubnativeConfigManager downloadConfigWithRequest:requestModel];
    } else {
        // Serve stored config
        [PubnativeConfigManager serveStoredConfigWithRequest:requestModel];
    }
}

+ (BOOL)storedConfigNeedsUpdateWithAppToken:(NSString*)appToken
{
    BOOL result = YES;
    
    PubnativeConfigModel    *storedModel    = [PubnativeConfigManager getStoredConfig];
    NSString                *storedAppToken = [PubnativeConfigManager getStoredAppToken];
    NSTimeInterval          storedTimestamp = [PubnativeConfigManager getStoredTimestamp];
    
    if(storedModel && storedAppToken && storedTimestamp){
        NSNumber *refreshInMinutes = (NSNumber*) [storedModel.globals objectForKey:CONFIG_GLOBAL_KEY_REFRESH];
        
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

+ (void)serveStoredConfigWithRequest:(PubnativeConfigRequestModel*)requestModel
{
    PubnativeConfigModel *storedConfig = [PubnativeConfigManager getStoredConfig];
    if(!storedConfig){
        NSLog(@"PubnativeConfigManager - error serving stored config, no previous config detected");
    }
    [PubnativeConfigManager invokeDidFinishWithModel:storedConfig
                                            delegate:requestModel.delegate];
}

#pragma mark - QUEUE -
+ (void)enqueueRequestModel:(PubnativeConfigRequestModel*)request
{
    if(request &&
       request.delegate &&
       request.appToken && [request.appToken length] > 0)
    {
        if(![PubnativeConfigManager sharedInstance].requestQueue){
            [PubnativeConfigManager sharedInstance].requestQueue = [[NSMutableArray alloc] init];
        }
        [[PubnativeConfigManager sharedInstance].requestQueue addObject:request];
    }
}

+ (PubnativeConfigRequestModel*)dequeueRequestDelegate
{
    PubnativeConfigRequestModel *result = nil;
    
    if([PubnativeConfigManager sharedInstance].requestQueue &&
       [[PubnativeConfigManager sharedInstance].requestQueue count] > 0){
        
        result = [[PubnativeConfigManager sharedInstance].requestQueue objectAtIndex:0];
        [[PubnativeConfigManager sharedInstance].requestQueue removeObjectAtIndex:0];
    }
    return result;
}

#pragma mark - DOWNLOAD -

+ (NSString*)configBaseURL
{
    NSString *result = kDefaultConfigURL;
    PubnativeConfigModel *storedConfig = [PubnativeConfigManager getStoredConfig];
    if(storedConfig && ![storedConfig isEmpty]){
        result = (NSString*)storedConfig.globals[CONFIG_GLOBAL_KEY_CONFIG_URL];
    }
    return result;
}

+ (NSString*)configRequestURLWithRequest:(PubnativeConfigRequestModel*)request
{
    NSString *result = [PubnativeConfigManager configBaseURL];
    result = [NSString stringWithFormat:@"%@?%@=%@", result, kAppTokenURLParameter, request.appToken];
    if(request.extras) {
        for (NSString *key in request.extras) {
            NSString *value = request.extras[key];
            if(key && key.length > 0 && value && value.length > 0) {
                result = [NSString stringWithFormat:@"%@&%@=%@", result, key, value];
            }
        }
    }
    return result;
}

+ (void)downloadConfigWithRequest:(PubnativeConfigRequestModel*)request
{
    if(request && request.appToken && request.appToken.length > 0) {
        
        NSString *url = [PubnativeConfigManager configRequestURLWithRequest:request];
        __block PubnativeConfigRequestModel *requestModelBlock = request;
        [PubnativeHttpRequest requestWithURL:url
                        andCompletionHandler:^(NSString *result, NSError *error) {
            if (error) {
                [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
            } else {
                
                NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSError *dataError;
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                               options:NSJSONReadingMutableContainers
                                                                                 error:&dataError];
                if (dataError) {
                    NSLog(@"PubnativeConfigManager - data error: %@", dataError);
                    [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                } else {
                    PubnativeConfigAPIResponseModel *apiResponse = [PubnativeConfigAPIResponseModel modelWithDictionary:jsonDictionary];
                    
                    if (apiResponse) {
                        
                        if ([apiResponse isSuccess]) {
                            
                            [PubnativeConfigManager processDownloadedConfig:apiResponse.config
                                                               withAppToken:requestModelBlock.appToken];
                            [PubnativeConfigManager serveStoredConfigWithRequest:requestModelBlock];
                
                        } else {
                        
                            NSLog(@"PubnativeConfigManager - server error: %@", apiResponse.error_message);
                            [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                        }
                        
                    } else {
                        
                        NSLog(@"PubnativeConfigManager - parsing error");
                        [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                    }
                }
            }
        }];
    } else {
        
        [PubnativeConfigManager serveStoredConfigWithRequest:request];
    }
}


+ (void)processDownloadedConfig:(PubnativeConfigModel*)newConfig
                   withAppToken:(NSString*)appToken
{
    if (appToken || appToken.length > 0 || newConfig || ![newConfig isEmpty]) {
        
        [PubnativeConfigManager updateDeliveryManagerWithNewConfig:newConfig];
        [PubnativeConfigManager updateStoredConfig:newConfig
                                      withAppToken:appToken];
    } else {
        
        NSLog(@"PubnativeConfigManager - Error: ");
    }
}

+ (void)updateDeliveryManagerWithNewConfig:(PubnativeConfigModel*)newConfig
{
    if (newConfig){
        
        PubnativeConfigModel *oldConfig = [PubnativeConfigManager getStoredConfig];
        
        if (oldConfig){
            
            for (NSString *placement in oldConfig.placements.allKeys) {
                
                PubnativePlacementModel *newPlacement = [newConfig placementWithName:placement];
                PubnativePlacementModel *oldPlacement = [oldConfig placementWithName:placement];
                if (newPlacement == nil) {
                    
                    [PubnativeDeliveryManager resetPacingDateForPlacementName:placement];
                    [PubnativeDeliveryManager resetDailyImpressionCountForPlacementName:placement];
                    [PubnativeDeliveryManager resetHourlyImpressionCountForPlacementName:placement];
                    
                } else {
                    
                    if (oldPlacement.delivery_rule.imp_cap_hour != newPlacement.delivery_rule.imp_cap_hour) {
                        [PubnativeDeliveryManager resetHourlyImpressionCountForPlacementName:placement];
                    }
                    
                    if (oldPlacement.delivery_rule.imp_cap_day != newPlacement.delivery_rule.imp_cap_day) {
                        [PubnativeDeliveryManager resetDailyImpressionCountForPlacementName:placement];
                    }
                    
                    if ((oldPlacement.delivery_rule.pacing_cap_minute != newPlacement.delivery_rule.pacing_cap_minute)||
                        (oldPlacement.delivery_rule.pacing_cap_hour != newPlacement.delivery_rule.pacing_cap_hour)){
                        [PubnativeDeliveryManager resetPacingDateForPlacementName:placement];
                    }
                }
            }
        }
    }
}

+ (void)updateStoredConfig:(PubnativeConfigModel*)model
              withAppToken:(NSString*)appToken
{
    if(appToken && [appToken length] > 0 &&
       model && ![model isEmpty]){
        [PubnativeConfigManager setStoredConfig:model];
        [PubnativeConfigManager setStoredAppToken:appToken];
        [PubnativeConfigManager setStoredTimestamp:[[NSDate date] timeIntervalSince1970]];
    }
}

#pragma mark Callback helpers

+ (void)invokeDidFinishWithModel:(PubnativeConfigModel*)model
                        delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate
{
    if(delegate &&
       [delegate respondsToSelector:@selector(configDidFinishWithModel:)]){
        [delegate configDidFinishWithModel:model];
    }
    [PubnativeConfigManager sharedInstance].idle = YES;
    [PubnativeConfigManager doNextRequest];
}

#pragma mark - NSUserDefaults -

#pragma mark Timestamp

+ (void)setStoredTimestamp:(NSTimeInterval)timestamp
{
    if(timestamp > 0){
        [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:kUserDefaultsStoredTimestampKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredTimestampKey];
    }
}

+ (NSTimeInterval)getStoredTimestamp
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsStoredTimestampKey];
}

#pragma mark AppToken

+ (void)setStoredAppToken:(NSString*)appToken
{
    if(appToken && [appToken length] > 0){
        [[NSUserDefaults standardUserDefaults] setObject:appToken forKey:kUserDefaultsStoredAppTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredAppTokenKey];
    }
}

+ (NSString*)getStoredAppToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsStoredAppTokenKey];
}

#pragma mark Config

+ (void)setStoredConfig:(PubnativeConfigModel*)model
{
    if(model && ![model isEmpty])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[model toDictionary]
                                                           options:0
                                                             error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:kUserDefaultsStoredConfigKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredConfigKey];
    }
}

+ (PubnativeConfigModel*)getStoredConfig
{
    PubnativeConfigModel *result;
    
    NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsStoredConfigKey];
    
    if(jsonData){
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        result = [PubnativeConfigModel modelWithDictionary:jsonDictionary];
    }
    return result;
}

@end
