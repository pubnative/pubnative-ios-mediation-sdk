//
//  PubnativeNetworkRequest.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkRequest.h"
#import "PubnativeConfigManager.h"
#import "PubnativeNetworkAdapterFactory.h"
#import "PubnativeDeliveryRuleModel.h"
#import "PubnativeDeliveryManager.h"
#import "PubnativeAdModel.h"
#import "PubnativeInsightModel.h"
#import "PubnativeAdTargetingModel.h"
#import "PubnativeReachability.h"


NSString * const PNTrackingAppTokenKey  = @"app_token";
NSString * const PNTrackingRequestIDKey = @"reqid";
NSString * const kPubnativeNetworkRequestStoredConfigKey = @"net.pubnative.mediation.PubnativeConfigManager.configJSON";

@interface PubnativeNetworkRequest () <PubnativeNetworkAdapterDelegate, PubnativeConfigManagerDelegate>

@property (nonatomic, strong)NSString                                   *placementName;
@property (nonatomic, strong)NSString                                   *appToken;
@property (nonatomic, strong)NSString                                   *requestID;
@property (nonatomic, strong)PubnativeConfigModel                       *config;
@property (nonatomic, strong)PubnativeAdModel                           *ad;
@property (nonatomic, strong)NSObject <PubnativeNetworkRequestDelegate> *delegate;
@property (nonatomic, strong)NSMutableDictionary<NSString*, NSString*>  *requestParameters;
@property (nonatomic, assign)NSInteger                                  currentNetworkIndex;
@property (nonatomic, assign)BOOL                                       isRunning;
@property (nonatomic, strong)PubnativeInsightModel                      *insight;
@property (nonatomic, strong)PubnativeAdTargetingModel                  *targeting;
@property (nonatomic, assign)NSTimeInterval                             startTimestamp;

@end

@implementation PubnativeNetworkRequest

#pragma mark - PubnativeNetworkRequest -

#pragma mark Public

- (void)startWithAppToken:(NSString*)appToken
            placementName:(NSString*)placementName
                 delegate:(NSObject<PubnativeNetworkRequestDelegate>*)delegate
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
                if(self.targeting) {
                    [extras setDictionary:[self.targeting toDictionary]];
                }
                [extras setDictionary:[self configExtras]];
                [PubnativeConfigManager configWithAppToken:appToken
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

- (NSDictionary*)configExtras {
    
    NSMutableDictionary *extras = [NSMutableDictionary dictionary];
    [extras setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    PubnativeReachability *reachability = [PubnativeReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    if(PubnativeNetworkStatus_ReachableViaWiFi == reachability.currentReachabilityStatus) {
        [extras setObject:kPubnativeInsightDataModelConnectionTypeWiFi forKey:@"connection_type"];
    } else {
        [extras setObject:kPubnativeInsightDataModelConnectionTypeCellular forKey:@"connection_type"];
    }
    [extras setObject:[[UIDevice currentDevice] name] forKey:@"device_name"];
    return extras;
}

- (void)setParameterWithKey:(NSString*)key value:(NSString*)value {
    
    if(self.requestParameters == nil){
        self.requestParameters = [NSMutableDictionary dictionary];
    }
    [self.requestParameters setObject:value forKey:key];
}

- (void)setTargeting:(PubnativeAdTargetingModel *)targeting
{
    self.targeting = targeting;
}

#pragma mark Private

- (void)startRequestWithConfig:(PubnativeConfigModel*)config
{
    //Check placements are available
    self.config = config;
    
    if ([self.config isEmpty]) {
        
        NSError *error = [NSError errorWithDomain:@"Error: Empty config retrieved by the server"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
        
    } else {
        
        PubnativePlacementModel *placement = [self.config placementWithName:self.placementName];
        if (placement == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: placement with name %@ not found in config", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else if (placement.delivery_rule == nil || placement.priority_rules == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: config contains null elements for placement %@ ", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else if ([placement.delivery_rule isDisabled]) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: placement %@ is disabled", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else if ([placement.delivery_rule isFrequencyCapReachedWithPlacement:self.placementName]) {
        
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: %@ - (frequency_cap) too many ads", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        
        } else if (placement.priority_rules.count == 0) {
            
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
    PubnativePlacementModel *placementModel = [self.config placementWithName:self.placementName];
    PubnativeDeliveryRuleModel *deliveryRuleModel = placementModel.delivery_rule;
    NSString *impressionUrl = (NSString*)self.config.globals[CONFIG_GLOBAL_KEY_IMPRESSION_BEACON];
    NSString *requestUrl = (NSString*)self.config.globals[CONFIG_GLOBAL_KEY_REQUEST_BEACON];
    NSString *clickUrl = (NSString*)self.config.globals[CONFIG_GLOBAL_KEY_CLICK_BEACON];
    // Params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.appToken forKey:@"app_token"];
    [params setObject:self.requestID forKey:@"reqid"];
    if (self.requestParameters) {
        [params addEntriesFromDictionary:self.requestParameters];
    }
    self.insight = [[PubnativeInsightModel alloc] init];
    self.insight.impressionInsightUrl = impressionUrl;
    self.insight.requestInsightUrl = requestUrl;
    self.insight.clickInsightUrl = clickUrl;
    self.insight.placementName = self.placementName;
    self.insight.appToken = self.appToken;
    self.insight.params = params;
    
    PubnativeInsightDataModel *data = [[PubnativeInsightDataModel alloc] initWithTargeting:self.targeting];
    [data fillWithDefaults];
    data.placement_name = self.placementName;
    data.delivery_segment_ids = deliveryRuleModel.segment_ids;
    data.ad_format_code = placementModel.ad_format_code;
    self.insight.data = data;
    [self startRequest];
}

- (void)startRequest {
    
    PubnativeDeliveryRuleModel *deliveryRuleModel = [self.config placementWithName:self.placementName].delivery_rule;
    
    BOOL needsNewAd = YES;
    
    NSDate *pacingDate = [PubnativeDeliveryManager pacingDateForPlacementName:self.placementName];
    NSDate *currentdate = [NSDate date];
    NSTimeInterval intervalInSeconds = [currentdate timeIntervalSinceDate:pacingDate];
    NSTimeInterval elapsedMinutes = (intervalInSeconds/60);
    NSTimeInterval elapsedHours = (intervalInSeconds/3600);
    
    // If there is a pacing cap set and the elapsed time still didn't time for that pacing cap, we don't refresh
    if (([deliveryRuleModel.pacing_cap_minute doubleValue] > 0 && elapsedMinutes < [deliveryRuleModel.pacing_cap_minute doubleValue])
        || ([deliveryRuleModel.pacing_cap_hour doubleValue] > 0 && elapsedHours < [deliveryRuleModel.pacing_cap_hour doubleValue])){
        
        needsNewAd = NO;
    }
    
    if(needsNewAd) {
        
        [self doNextNetworkRequest];
        
    } else if(self.ad) {
        
        [self invokeDidLoad:self.ad];
        
    } else {
        
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: (pacing_cap) too many ads for placement %@", self.placementName]
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
    
}

- (void)doNextNetworkRequest
{
    //Check if priority rules avaliable
    self.currentNetworkIndex++;
    PubnativePriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                                 andIndex:self.currentNetworkIndex];
    if (priorityRule) {
        
        PubnativeNetworkModel *network = [self.config networkWithID:priorityRule.network_code];
        if (network) {
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithAdapterName:network.adapter];
            if (adapter) {
                NSMutableDictionary<NSString*, NSString*> *extras = [NSMutableDictionary dictionary];
                [extras setObject:self.requestID forKey:PNTrackingRequestIDKey];
                if (self.targeting) {
                    [extras addEntriesFromDictionary:[self.targeting toDictionary]];
                }
                if(self.requestParameters){
                    [extras setDictionary:self.requestParameters];
                }
                if(self.config.request_params) {
                    [extras setDictionary:self.config.request_params];
                }
                [adapter startWithData:network.params
                               timeout:[network.timeout doubleValue]
                                extras:extras
                              delegate:self];
                
            } else {
                
                NSLog(@"PubnativeNetworkRequest.doNextNetworkRequest- Error: Invalid adapter");
                NSError *error = [NSError errorWithDomain:@"Adapter doesn't implements this type"
                                                     code:0
                                                 userInfo:nil];
                [self.insight trackUnreachableNetworkWithPriorityRuleModel:priorityRule
                                                              responseTime:0
                                                                     error:error];
                [self doNextNetworkRequest];
            }
        } else {
            
            NSLog(@"PubnativeNetworkRequest.doNextNetworkRequest- Error: Invalid network code");
            [self doNextNetworkRequest];
        }
        
    } else {
        
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.doNextNetworkRequest- Error: No fill"
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

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    self.isRunning = false;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didLoad:)]) {
        [self.delegate pubnativeRequest:self didLoad:ad];
    }
    self.delegate = nil;
}

#pragma mark - CALLBACKS -

#pragma mark PubnativeConfigManagerDelegate

- (void)configDidFinishWithModel:(PubnativeConfigModel*)model
{
    if(model) {
        [self startRequestWithConfig:model];
    } else {
        NSError *configError = [NSError errorWithDomain:@"PubnativeNetworkRequest - config error" code:0 userInfo:nil];
        [self invokeDidFail:configError];
    }
}

#pragma mark PubnativeNetworkAdapterDelegate

- (void)adapterRequestDidStart:(PubnativeNetworkAdapter*)adapter
{
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad
{
    [PubnativeDeliveryManager updatePacingDateForPlacementName:self.placementName];
    // TODO: remove setting the app token since it should be inside the insight data
    PubnativePriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                                 andIndex:self.currentNetworkIndex];
    NSTimeInterval deltaTimeResponse = ([[NSDate date] timeIntervalSince1970] - self.startTimestamp) * 1000;
    NSNumber *responseTime = [NSNumber numberWithInteger:round(deltaTimeResponse)];
    
    if (ad) {
        self.ad = ad;
        // Track succeded network
        [self.insight trackSuccededNetworkWithPriorityRuleModel:priorityRule responseTime:responseTime];
        [self.insight sendRequestInsight];
        // Default tracking data
        
        self.ad.insightModel = self.insight;
        [self invokeDidLoad:self.ad];
    } else {
        NSLog(@"PubnativeNetworkRequest.adapter - No fill");
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.adapter - No fill"
                                             code:0
                                         userInfo:nil];
        [self.insight trackAttemptedNetworkWithPriorityRuleModel:priorityRule
                                                    responseTime:responseTime
                                                           error:error];
        [self doNextNetworkRequest];
    }
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError*)error
{
    NSLog(@"PubnativeNetworkRequest.adapter:requestDidFail:- Error %@",[error domain]);
    [self doNextNetworkRequest];
}

@end