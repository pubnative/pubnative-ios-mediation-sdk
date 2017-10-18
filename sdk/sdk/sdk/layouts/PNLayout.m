//
//  PNLayout.m
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayout+Internal.h"
#import "PNLayoutAdapter.h"
#import "PNLayoutAdapterFactory.h"
#import "PNInsightModel.h"
#import "PNConfigModel.h"
#import "PNNetworkModel.h"
#import "PNConfigManager.h"
#import "PNError.h"

NSString * const kPNLayoutTrackingAppTokenKey       = @"app_token";
NSString * const kPNLayoutTrackingRequestIDKey      = @"reqid";

@interface PNLayout()<PNLayoutAdapterLoadDelegate, PNLayoutAdapterFetchDelegate, PNConfigManagerDelegate, PNLayoutAdapterTrackDelegate>

@property (nonatomic, strong) NSString *placementName;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) PNConfigModel *config;
@property (nonatomic, assign) NSInteger currentNetworkIndex;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) PNInsightModel *insight;
@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *requestParameters;
@property (nonatomic, strong) PNLayoutAdapter *adapter;
@property (nonatomic, strong) NSObject<PNLayoutLoadDelegate> *loadDelegate;

@end

@implementation PNLayout

#pragma mark - NSObject -

- (void)dealloc
{
    self.placementName = nil;
    self.appToken = nil;
    self.requestID = nil;
    self.config = nil;
    self.requestParameters = nil;
    self.insight = nil;
    self.adapter = nil;
}

#pragma mark - Layout -

- (void)loadWithAppToken:(NSString *)appToken
               placement:(NSString *)placement
                delegate:(NSObject<PNLayoutLoadDelegate> *)delegate
{
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"request is currently running, droping this call" code:0 userInfo:nil];
        [self invokeDidFailWithError:runningError];
    } else if (delegate == nil) {
        NSLog(@"Delegate not specified, droping this call");
    } else if (appToken == nil || appToken.length == 0) {
        NSLog(@"PNLayout - invalid app token");
        [self invokeDidFailWithError:[PNError errorWithCode:PNError_layout_invalidParameters]];
    } else if (placement == nil || placement.length == 0) {
        NSLog(@"PNLayout - invalid placement");
        [self invokeDidFailWithError:[PNError errorWithCode:PNError_layout_invalidParameters]];
    } else {
        self.config = nil;
        self.insight = nil;
        self.adapter = nil;
        self.appToken = appToken;
        self.placementName = placement;
        self.loadDelegate = delegate;
        self.currentNetworkIndex = -1;
        self.requestID = [[NSUUID UUID] UUIDString];
        NSMutableDictionary<NSString*, NSString*> *extras = [NSMutableDictionary dictionary];
        if(self.requestParameters){
            [extras setDictionary:self.requestParameters];
        }
        self.isRunning = YES;
        [PNConfigManager configWithAppToken:appToken
                                     extras:extras
                                   delegate:self];
    }    
}

- (void)startRequestWithConfig:(PNConfigModel*)config
{
    if (config == nil || config.isEmpty) {
        NSError *error = [NSError errorWithDomain:@"Error: Empty config retrieved by the server"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFailWithError:error];
    } else {
        self.config = config;
        PNPlacementModel *placement = [self.config placementWithName:self.placementName];
        if (placement == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: placement with name %@ not found in config", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFailWithError:error];
            
        } else if (placement.priority_rules == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: config contains null elements for placement %@ ", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFailWithError:error];
            
        }  else if (placement.priority_rules.count == 0) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: no networks configured for placement %@", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFailWithError:error];
            
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.appToken forKey:kPNLayoutTrackingAppTokenKey];
    [params setObject:self.requestID forKey:kPNLayoutTrackingRequestIDKey];
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
    self.currentNetworkIndex++;
    PNPriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                          andIndex:self.currentNetworkIndex];
    if (priorityRule) {
        
        PNNetworkModel *network = [self.config networkWithID:priorityRule.network_code];
        if (network) {
            PNLayoutAdapter *adapter = [[self factory] adapterWithName:network.adapter];
            if (adapter) {
                adapter.networkConfig = network;
                adapter.insight = self.insight;
                adapter.data = network.params;
                adapter.isCPICacheEnabled = network.isCPACacheEnabled;
                adapter.loadDelegate = self;
                [adapter execute:[network.timeout doubleValue]];
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
        [self invokeDidFailWithError:error];
    }
}

- (void)startTrackingView
{
    if (self.adapter) {
        self.adapter.trackDelegate = self;
        [self.adapter startTracking];
    } else {
        NSLog(@"PNLayout.startTrackingView - Error: Ad not loaded, or failed during load, please reload it again");
    }
}

- (void)stopTrackingView
{
    if (self.adapter) {
        [self.adapter stopTracking];
        self.adapter.trackDelegate = nil;
    } else {
        NSLog(@"PNLayout.stopTrackingView - Error: Ad not loaded, or failed during load, please reload it again");
    }
}

#pragma mark - Callback helpers -

- (void)invokeDidFinish
{
    NSObject<PNLayoutLoadDelegate> *delegate = self.loadDelegate;
    self.isRunning = NO;
    self.loadDelegate = nil;
    if (delegate && [delegate respondsToSelector:@selector(layoutDidFinishLoading:)]) {
        [delegate layoutDidFinishLoading:self];
    }
}

- (void)invokeDidFailWithError:(NSError *)error
{
    NSObject<PNLayoutLoadDelegate> *delegate = self.loadDelegate;
    self.isRunning = NO;
    self.loadDelegate = nil;
    if (delegate && [delegate respondsToSelector:@selector(layout:didFailLoading:)]) {
        [delegate layout:self didFailLoading:error];
    }
}

- (void)invokeClick
{
    if (self.insight) {
        [self.insight sendClickInsight];
    }
    
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(layoutTrackClick:)]) {
        [self.trackDelegate layoutTrackClick:self];
    }
}

- (void)invokeImpression
{
    if (self.insight) {
        [self.insight sendImpressionInsight];
    }
    
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(layoutTrackImpression:)]) {
        [self.trackDelegate layoutTrackImpression:self];
    }
}

#pragma mark - PNLayoutAdapterLoadDelegate -

- (void)layoutAdapterDidFinishLoading:(PNLayoutAdapter *)adapter
{
    PNPriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                          andIndex:self.currentNetworkIndex];
    self.adapter = adapter;
    [self.insight trackSuccededNetworkWithPriorityRuleModel:priorityRule
                                               responseTime:[self.adapter elapsedTime]];
    [self.insight sendRequestInsight];
    self.adapter.fetchDelegate = self;
    [self.adapter fetch];
}

- (void)layoutAdapter:(PNLayoutAdapter *)adapter didFailLoading:(NSError *)error
{
    PNPriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                          andIndex:self.currentNetworkIndex];
    
    if ([error isKindOfClass:[PNError class]]) {
        [self.insight trackUnreachableNetworkWithPriorityRuleModel:priorityRule
                                                      responseTime:[self.adapter elapsedTime]
                                                             error:error];
    } else {
        [self.insight trackAttemptedNetworkWithPriorityRuleModel:priorityRule
                                                    responseTime:[self.adapter elapsedTime]
                                                           error:error];
    }
    
    [self doNextNetworkRequest];
}

#pragma mark - PNLayoutAdapterFetchDelegate -

- (void)layoutAdapterDidFinishFetching:(PNLayoutAdapter *)adapter
{
    [self invokeDidFinish];
}

- (void)layoutAdapter:(PNLayoutAdapter *)adapter didFailFetching:(NSError*)error
{
    [self invokeDidFailWithError:error];
}

#pragma mark - PNConfigManagerDelegate -

- (void)configDidFinishWithModel:(PNConfigModel *)model
{
    [self startRequestWithConfig:model];
}

#pragma mark - PNLayoutAdapterTrackDelegate -

- (void)layoutAdapterTrackImpression:(PNLayoutAdapter *)adapter
{
    [self invokeImpression];
}

- (void)layoutAdapterTrackClick:(PNLayoutAdapter *)adapter
{
    [self invokeClick];
}

@end
