//
//  PNInsightDataModel.m
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNInsightDataModel.h"
#import "PNReachability.h"
#import "PNSettings.h"

NSString * const kPNInsightDataModelConnectionTypeWiFi       = @"wifi";
NSString * const kPNInsightDataModelConnectionTypeCellular   = @"cellular";

@implementation PNInsightDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.retry = @0;
    }
    return self;
}

- (void)dealloc
{
    self.network = nil;
    self.attempted_networks = nil;
    self.unreachable_networks = nil;
    self.delivery_segment_ids = nil;
    self.networks = nil;
    self.placement_name = nil;
    self.ad_format_code = nil;
    self.creative_url = nil;
    self.video_start = nil;
    self.video_complete = nil;
    self.retry = nil;
    self.retry_error = nil;
    self.generated_at = nil;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
{
    self = [super init];
    if(self) {
        self.network = dictionary[@"network"];
        self.attempted_networks = dictionary[@"attempted_networks"];
        self.unreachable_networks = dictionary[@"unreachable_networks"];
        self.delivery_segment_ids = dictionary[@"delivery_segment_ids"];
        self.networks = dictionary[@"networks"];
        self.placement_name = dictionary[@"placement_name"];
        self.ad_format_code = dictionary[@"ad_format_code"];
        self.creative_url = dictionary[@"creative_url"];
        self.retry = dictionary[@"retry"];
        self.retry_error = dictionary[@"retry_error"];
        self.generated_at = dictionary[@"generated_at"];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"network"] = self.network;
    result[@"attempted_networks"] = self.attempted_networks;
    result[@"unreachable_networks"] = self.unreachable_networks;
    result[@"delivery_segment_ids"] = self.delivery_segment_ids;
    NSMutableArray *networksArray = [NSMutableArray array];
    for (PNInsightNetworkModel *networkObject in self.networks) {
        if ([networkObject isKindOfClass:[NSDictionary class]]) {
            [networksArray addObject:networkObject];
        }
        else {
            NSDictionary *networkDictionary = [networkObject toDictionary];
            [networksArray addObject:networkDictionary];
        }
    }
    result[@"networks"] = networksArray;
    result[@"placement_name"] = self.placement_name;
    result[@"ad_format_code"] = self.ad_format_code;
    result[@"creative_url"] = self.creative_url;
    result[@"retry"] = self.retry;
    result[@"retry_error"] = self.retry_error;
    result[@"generated_at"] = self.generated_at;
    
    // TRACKING PARAMETERS
    result[@"sdk_version"] = [PNSettings sharedInstance].sdkVersion;
    result[@"pub_app_version"] = [PNSettings sharedInstance].appVersion;
    result[@"pub_app_bundle_id"] = [PNSettings sharedInstance].appBundleID;
    result[@"os_version"] = [PNSettings sharedInstance].osVersion;
    result[@"user_uid"] = [PNSettings sharedInstance].advertisingId;
    result[@"device_name"] = [PNSettings sharedInstance].deviceName;
    result[@"coppa"] = [NSNumber numberWithBool:[PNSettings sharedInstance].coppa];
    result[@"connection_type"] = [self connectionType];
    
    NSDictionary *targetingDictionary = [[PNSettings sharedInstance].targeting toDictionaryWithIAP];
    if(targetingDictionary) {
        [result addEntriesFromDictionary:targetingDictionary];
    }
    return result;
}

- (void)addAttemptedNetworkWithNetworkCode:(NSString *)networkCode
{
    if (networkCode && networkCode.length > 0) {
        if (self.attempted_networks == nil) {
            self.attempted_networks = [NSArray array];
        }
        NSMutableArray *stringArray = [self.attempted_networks mutableCopy];
        [stringArray addObject:networkCode];
        self.attempted_networks = stringArray;
    }
}

- (void)addUnreachableNetworkWithNetworkCode:(NSString *)networkCode
{
    if (networkCode && networkCode.length > 0) {
        if (self.unreachable_networks == nil) {
            self.unreachable_networks = [NSArray array];
        }
        NSMutableArray *stringArray = [self.unreachable_networks mutableCopy];
        [stringArray addObject:networkCode];
        self.unreachable_networks = stringArray;
    }
}

- (void)addNetworkWithPriorityRuleModel:(PNPriorityRuleModel *)priorityRuleModel
                           responseTime:(NSTimeInterval)responseTime
                             crashModel:(PNInsightCrashModel *)crashModel
{
    if (priorityRuleModel) {
        if (self.networks == nil) {
            self.networks = [NSArray array];
        }
        PNInsightNetworkModel *networkModel = [[PNInsightNetworkModel alloc] init];
        networkModel.code = priorityRuleModel.network_code;
        networkModel.priority_rule_id = priorityRuleModel.identifier;
        networkModel.priority_segment_ids = priorityRuleModel.segment_ids;
        networkModel.response_time = [NSNumber numberWithInteger:round(responseTime)];
        if (crashModel) {
            networkModel.crash_report = crashModel;
        }
        NSMutableArray *networksArray = [self.networks mutableCopy];
        [networksArray addObject:networkModel];
        self.networks = networksArray;
    }
}

- (NSString*)connectionType
{
    NSString *result = nil;
    PNReachability *reachability = [PNReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    if(PNNetworkStatus_ReachableViaWiFi == reachability.currentReachabilityStatus) {
        result = kPNInsightDataModelConnectionTypeWiFi;
    } else {
        result = kPNInsightDataModelConnectionTypeCellular;
    }
    [reachability stopNotifier];
    return result;
}

@end
