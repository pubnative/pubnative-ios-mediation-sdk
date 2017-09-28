//
//  PNRequest.m
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNRequest.h"
#import "PNConfigManager.h"
#import "PNNetworkAdapterFactory.h"
#import "PNAdModel+Fetching.h"
#import "PNAdModel+Internal.h"
#import "PNInsightModel.h"
#import "PNReachability.h"
#import "PNError.h"

NSString * const kPNRequestTrackingAppTokenKey       = @"app_token";
NSString * const kPNRequestTrackingRequestIDKey      = @"reqid";
NSString * const kPNRequestStoredConfigKey           = @"PNConfigManager.configJSON";

@interface PNRequest () <PNNetworkAdapterDelegate, PNConfigManagerDelegate, PNAdModelFetchDelegate>

@property (nonatomic, strong)NSString                                   *placementName;
@property (nonatomic, strong)NSString                                   *appToken;
@property (nonatomic, strong)NSString                                   *requestID;
@property (nonatomic, strong)PNConfigModel                              *config;
@property (nonatomic, strong)NSObject <PNRequestDelegate>               *delegate;
@property (nonatomic, strong)NSMutableDictionary<NSString*, NSString*>  *requestParameters;
@property (nonatomic, assign)NSInteger                                  currentNetworkIndex;
@property (nonatomic, assign)BOOL                                       isRunning;
@property (nonatomic, strong)PNInsightModel                             *insight;
@property (nonatomic, assign)NSTimeInterval                             startTimestamp;
@property (nonatomic, strong)PNAdModel                                  *currentAd;

@end

@implementation PNRequest

#pragma mark - NSObject -

- (void)dealloc
{
    self.placementName = nil;
    self.appToken = nil;
    self.requestID = nil;
    self.config = nil;
    self.delegate = nil;
    self.requestParameters = nil;
    self.insight = nil;
    self.currentAd = nil;
}

#pragma mark - PNRequest -

#pragma mark Public

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheResources = YES;
    }
    return self;
}

- (void)startWithAppToken:(NSString*)appToken
            placementName:(NSString*)placementName
                 delegate:(NSObject<PNRequestDelegate>*)delegate
{
    if (delegate) {
        
        self.delegate = delegate;
        
        if(self.isRunning) {
            NSLog(@"Request already running, dropping the call");
        } else {
            
            self.isRunning = YES;
            [self invokeDidStart];
            
            if (appToken && [appToken length] > 0 &&
                placementName && [placementName length] > 0) {
                
                //set the data
                self.appToken = appToken;
                self.placementName = placementName;
                self.currentNetworkIndex = -1;
                self.requestID = [[NSUUID UUID] UUIDString];
                NSMutableDictionary<NSString*, NSString*> *extras = [NSMutableDictionary dictionary];
                if(self.requestParameters){
                    [extras setDictionary:self.requestParameters];
                }
                [PNConfigManager configWithAppToken:appToken
                                                extras:extras
                                              delegate:self];
                
            } else {
                NSError *error = [NSError errorWithDomain:@"Error: Invalid AppToken/PlacementID"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        }
    } else {
        NSLog(@"Delegate not specified, droping this call");
    }
}

- (void)addParameterWithKey:(NSString*)key value:(NSString*)value {
    
    if(self.requestParameters == nil){
        self.requestParameters = [NSMutableDictionary dictionary];
    }
    [self.requestParameters setObject:value forKey:key];
}

#pragma mark Private

- (void)startRequestWithConfig:(PNConfigModel*)config
{
    //Check placements are available
    if (config == nil || config.isEmpty) {
        
        NSError *error = [NSError errorWithDomain:@"Error: Empty config retrieved by the server"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
        
    } else {
        
        self.config = config;
        PNPlacementModel *placement = [self.config placementWithName:self.placementName];
        if (placement == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: placement with name %@ not found in config", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else if (placement.priority_rules == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: config contains null elements for placement %@ ", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        }  else if (placement.priority_rules.count == 0) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: no networks configured for placement %@", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else {
            
            [self startTracking];
        }
    }
}

- (void)startTracking
{
    PNPlacementModel *placementModel = [self.config placementWithName:self.placementName];
    NSString *impressionUrl = (NSString*)self.config.globals[PN_CONFIG_GLOBAL_KEY_IMPRESSION_BEACON];
    NSString *requestUrl = (NSString*)self.config.globals[PN_CONFIG_GLOBAL_KEY_REQUEST_BEACON];
    NSString *clickUrl = (NSString*)self.config.globals[PN_CONFIG_GLOBAL_KEY_CLICK_BEACON];
    // Params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.appToken forKey:kPNRequestTrackingAppTokenKey];
    [params setObject:self.requestID forKey:kPNRequestTrackingRequestIDKey];
    if (self.requestParameters) {
        [params addEntriesFromDictionary:self.requestParameters];
    }
    self.insight = [[PNInsightModel alloc] init];
    self.insight.impressionInsightUrl = impressionUrl;
    self.insight.requestInsightUrl = requestUrl;
    self.insight.clickInsightUrl = clickUrl;
    self.insight.placementName = self.placementName;
    self.insight.appToken = self.appToken;
    self.insight.params = params;
    
    PNInsightDataModel *data = [[PNInsightDataModel alloc] init];
    data.placement_name = self.placementName;
    data.ad_format_code = placementModel.ad_format_code;
    self.insight.data = data;
    [self doNextNetworkRequest];
}

- (void)doNextNetworkRequest
{
    //Check if priority rules avaliable
    self.currentNetworkIndex++;
    PNPriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                          andIndex:self.currentNetworkIndex];
    if (priorityRule) {
        
        PNNetworkModel *network = [self.config networkWithID:priorityRule.network_code];
        if (network) {
            PNNetworkAdapter *adapter = [PNNetworkAdapterFactory createApdaterWithAdapterName:network.adapter];
            if (adapter) {
                adapter.networkConfig = network;
                
                NSMutableDictionary<NSString*, NSString*> *extras = [NSMutableDictionary dictionary];
                [extras setObject:self.requestID forKey:kPNRequestTrackingRequestIDKey];
                if(self.requestParameters){
                    [extras setDictionary:self.requestParameters];
                }
                [adapter startWithExtras:extras
                                delegate:self];
                
            } else {
                
                NSLog(@"PNRequest.doNextNetworkRequest- Error: Invalid adapter");
                NSError *error = [NSError errorWithDomain:@"Adapter doesn't implements this type"
                                                     code:0
                                                 userInfo:nil];
                [self.insight trackUnreachableNetworkWithPriorityRuleModel:priorityRule
                                                              responseTime:0
                                                                     error:error];
                [self doNextNetworkRequest];
            }
        } else {
            
            NSLog(@"PNRequest.doNextNetworkRequest- Error: Invalid network code");
            [self doNextNetworkRequest];
        }
        
    } else {
        
        NSError *error = [NSError errorWithDomain:@"PNRequest.doNextNetworkRequest- Error: No fill"
                                             code:0
                                         userInfo:nil];
        [self.insight sendRequestInsight];
        [self invokeDidFail:error];
    }
}

#pragma mark Callback helpers

- (void)invokeDidStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequestDidStart:)]) {
        [self.delegate pubnativeRequestDidStart:self];
    }
}

- (void)invokeDidFail:(NSError*)error
{
    self.isRunning = false;
    if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didFail:)]){
        [self.delegate pubnativeRequest:self didFail:error];
    }
    self.delegate = nil;
}

- (void)invokeDidLoad:(PNAdModel*)ad
{
    self.isRunning = false;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didLoad:)]) {
        [self.delegate pubnativeRequest:self didLoad:ad];
    }
    self.delegate = nil;
}

#pragma mark - CALLBACKS -

#pragma mark PNConfigManagerDelegate

- (void)configDidFinishWithModel:(PNConfigModel*)model
{
    [self startRequestWithConfig:model];
}

#pragma mark PNNetworkAdapterDelegate

- (void)adapterRequestDidStart:(PNNetworkAdapter*)adapter
{
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)adapter:(PNNetworkAdapter*)adapter requestDidLoad:(PNAdModel*)ad
{
    // TODO: remove setting the app token since it should be inside the insight data
    PNPriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                          andIndex:self.currentNetworkIndex];
    
    if (ad == nil) {
        NSLog(@"PNRequest.adapter - No fill");
        PNError *error = [PNError errorWithDomain:@"PNRequest.adapter - No fill"
                                                   code:0
                                               userInfo:nil];
        
        [self.insight trackAttemptedNetworkWithPriorityRuleModel:priorityRule
                                                    responseTime:[self elapsedTime]
                                                           error:error];
        [self doNextNetworkRequest];
    } else {
        // Track succeded network
        [self.insight trackSuccededNetworkWithPriorityRuleModel:priorityRule
                                                   responseTime:[self elapsedTime]];
        [self.insight sendRequestInsight];
        self.currentAd = ad;
        [self.currentAd setInsight:self.insight];
        [self requestDidLoad];
    }
}

- (void)requestDidLoad
{
    if(self.cacheResources) {
        [self.currentAd fetchAssetsWithDelegate:self];
    } else {
        [self invokeDidLoad:self.currentAd];
    }
}

- (void)adapter:(PNNetworkAdapter*)adapter requestDidFail:(NSError*)error
{
    PNPriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                          andIndex:self.currentNetworkIndex];
    
    if ([error isKindOfClass:[PNError class]]) {
        [self.insight trackUnreachableNetworkWithPriorityRuleModel:priorityRule
                                                      responseTime:[self elapsedTime]
                                                             error:error];
    } else {
        [self.insight trackAttemptedNetworkWithPriorityRuleModel:priorityRule
                                                    responseTime:[self elapsedTime]
                                                           error:error];
    }
    
    // Waterfall to the next network
    [self doNextNetworkRequest];
}

- (NSTimeInterval)elapsedTime {
    
    return ([[NSDate date] timeIntervalSince1970] - self.startTimestamp) * 1000;
}

#pragma mark PNAdModelFetchDelegate

- (void)pubnativeAdFetchDidFinish:(PNAdModel *)model
{
    [self invokeDidLoad:model];
}

- (void)pubnativeAdFetchDidFail:(PNAdModel *)model withError:(NSError *)error
{
    [self invokeDidFail:error];
}


@end

