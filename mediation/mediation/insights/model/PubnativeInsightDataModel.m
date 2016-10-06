//
//  PubnativeInsightDataModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "AdSupport/ASIdentifierManager.h"
#import "PubnativeInsightDataModel.h"
#import "PubnativeReachability.h"

NSString * const kPubnativeInsightDataModelConnectionTypeWiFi       = @"wifi";
NSString * const kPubnativeInsightDataModelConnectionTypeCellular   = @"cellular";
NSString * const kPubnativeInsightDataModelSdkVersion               = @"1.0.1";

@implementation PubnativeInsightDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.retry = @0;
    }
    return self;
}

- (instancetype)initWithTargeting:(PubnativeAdTargetingModel*)targeting
{
    self = [super init];
    self.age = targeting.age;
    self.education = targeting.education;
    self.interests = targeting.interests;
    self.gender = targeting.gender;
    self.iap = targeting.iap;
    self.iap_total = targeting.iap_total;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.network = dictionary[@"network"];
        self.attempted_networks = dictionary[@"attempted_networks"];
        self.unreachable_networks = dictionary[@"unreachable_networks"];
        self.delivery_segment_ids = dictionary[@"delivery_segment_ids"];
        self.networks = [PubnativeInsightNetworkModel parseArrayValues:dictionary[@"networks"]];
        self.placement_name = dictionary[@"placement_name"];
        self.pub_app_version = dictionary[@"pub_app_version"];
        self.pub_app_bundle_id = dictionary[@"pub_app_bundle_id"];
        self.os_version = dictionary[@"os_version"];
        self.sdk_version = dictionary[@"sdk_version"];
        self.user_uid = dictionary[@"user_uid"];
        self.connection_type = dictionary[@"connection_type"];
        self.device_name = dictionary[@"device_name"];
        self.ad_format_code = dictionary[@"ad_format_code"];
        self.creative_url = dictionary[@"creative_url"];
        self.video_start = dictionary[@"video_start"];
        self.video_complete = dictionary[@"video_complete"];
        self.retry = dictionary[@"retry"];
        self.retry_error = dictionary[@"retry_error"];
        self.age = dictionary[@"age"];
        self.education = dictionary[@"education"];
        self.interests = dictionary[@"interests"];
        self.gender = dictionary[@"gender"];
        self.keywords = dictionary[@"keywords"];
        self.iap = dictionary[@"iap"];
        self.iap_total = dictionary[@"iap_total"];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"network"] = self.network;
    result[@"attempted_networks"] = self.attempted_networks;
    result[@"unreachable_networks"] = self.unreachable_networks;
    result[@"delivery_segment_ids"] = self.delivery_segment_ids;
    NSMutableArray *networksArray = [NSMutableArray array];
    for (PubnativeInsightNetworkModel *networkObject in self.networks) {
        NSDictionary *networkDictionary = [networkObject toDictionary];
        [networksArray addObject:networkDictionary];
    }
    result[@"networks"] = networksArray;
    result[@"placement_name"] = self.placement_name;
    result[@"pub_app_version"] = self.pub_app_version;
    result[@"pub_app_bundle_id"] = self.pub_app_bundle_id;
    result[@"os_version"] = self.os_version;
    result[@"sdk_version"] = self.sdk_version;
    result[@"user_uid"] = self.user_uid;
    result[@"connection_type"] = self.connection_type;
    result[@"device_name"] = self.device_name;
    result[@"ad_format_code"] = self.ad_format_code;
    result[@"creative_url"] = self.creative_url;
    result[@"video_start"] = self.video_start;
    result[@"video_complete"] = self.video_complete;
    result[@"retry"] = self.retry;
    result[@"retry_error"] = self.retry_error;
    result[@"age"] = self.age;
    result[@"education"] = self.education;
    result[@"interests"] = self.interests;
    result[@"gender"] = self.gender;
    result[@"keywords"] = self.keywords;
    result[@"iap"] = self.iap;
    result[@"iap_total"] = self.iap_total;
    return result;
}

- (void)addAttemptedNetworkWithNetworkCode:(NSString *)networkCode
{
    if (networkCode && networkCode.length > 0) {
        if (self.attempted_networks) {
            self.attempted_networks = [[NSArray<NSString*> alloc] init];
        }
        NSMutableArray *stringArray = [self.attempted_networks mutableCopy];
        [stringArray addObject:networkCode];
        self.attempted_networks = stringArray;
    }
}

- (void)addUnreachableNetworkWithNetworkCode:(NSString *)networkCode
{
    if (networkCode && networkCode.length > 0) {
        if (self.unreachable_networks) {
            self.unreachable_networks = [[NSArray<NSString*> alloc] init];
        }
        NSMutableArray *stringArray = [self.unreachable_networks mutableCopy];
        [stringArray addObject:networkCode];
        self.unreachable_networks = stringArray;
    }
}

- (void)addNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel *)priorityRuleModel responseTime:(NSNumber *)responseTime crashModel:(PubnativeInsightCrashModel *)crashModel
{
    if (priorityRuleModel) {
        if (!self.networks) {
            self.networks = [[NSArray<PubnativeInsightNetworkModel*> alloc] init];
        }
        PubnativeInsightNetworkModel *networkModel = [[PubnativeInsightNetworkModel alloc] init];
        networkModel.code = priorityRuleModel.network_code;
        networkModel.priority_rule_id = priorityRuleModel.identifier;
        networkModel.priority_segment_ids = priorityRuleModel.segment_ids;
        networkModel.response_time = responseTime;
        if (crashModel) {
            networkModel.crash_report = crashModel;
        }
        NSMutableArray *networksArray = [self.networks mutableCopy];
        [networksArray addObject:networkModel];
        self.networks = networksArray;
    }
}

- (void)fillWithDefaults
{
    if (!self.pub_app_version) {
        self.pub_app_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    if (!self.pub_app_bundle_id) {
        self.pub_app_bundle_id = [[NSBundle mainBundle] bundleIdentifier];
    }
    if (!self.os_version) {
        self.os_version = [[UIDevice currentDevice] systemVersion];
    }
    if (!self.sdk_version) {
        self.sdk_version = kPubnativeInsightDataModelSdkVersion;
    }
    if (!self.connection_type) {
        
        PubnativeReachability *reachability = [PubnativeReachability reachabilityForInternetConnection];
        [reachability startNotifier];
        if(PubnativeNetworkStatus_ReachableViaWiFi == reachability.currentReachabilityStatus) {
            self.connection_type = kPubnativeInsightDataModelConnectionTypeWiFi;
        } else {
            self.connection_type = kPubnativeInsightDataModelConnectionTypeCellular;
        }
    }
    if (!self.device_name) {
        self.device_name = [[UIDevice currentDevice] name];
    }
    if (self.retry) {
        self.retry = @0;
    }
    
    if(NSClassFromString(@"ASIdentifierManager")){
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            self.user_uid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
}

@end