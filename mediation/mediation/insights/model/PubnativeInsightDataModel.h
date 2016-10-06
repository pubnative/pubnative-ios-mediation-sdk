//
//  PubnativeInsightDataModel.h
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeJSONModel.h"
#import "PubnativeInsightNetworkModel.h"
#import "PubnativePriorityRuleModel.h"
#import "PubnativeAdTargetingModel.h"

extern NSString * const kPubnativeInsightDataModelConnectionTypeWiFi;
extern NSString * const kPubnativeInsightDataModelConnectionTypeCellular;
extern NSString * const kPubnativeInsightDataModelSdkVersion;

@interface PubnativeInsightDataModel : PubnativeJSONModel

//// Tracking info
@property (nonatomic, strong) NSString                                  *network;
@property (nonatomic, strong) NSArray<NSString*>                        *attempted_networks;
@property (nonatomic, strong) NSArray<NSString*>                        *unreachable_networks;
@property (nonatomic, strong) NSArray<NSNumber*>                        *delivery_segment_ids;
@property (nonatomic, strong) NSArray<PubnativeInsightNetworkModel*>    *networks;
@property (nonatomic, strong) NSString                                  *placement_name;
@property (nonatomic, strong) NSString                                  *pub_app_version;
@property (nonatomic, strong) NSString                                  *pub_app_bundle_id;
@property (nonatomic, strong) NSString                                  *os_version;
@property (nonatomic, strong) NSString                                  *sdk_version;
@property (nonatomic, strong) NSString                                  *user_uid; // Apple IDFA
@property (nonatomic, strong) NSString                                  *connection_type; // “wifi” or “cellular"
@property (nonatomic, strong) NSString                                  *device_name;
@property (nonatomic, strong) NSString                                  *ad_format_code;
@property (nonatomic, strong) NSString                                  *creative_url; // Creative selected from the ad_format_code value of the config
@property (nonatomic, strong) NSNumber                                  *video_start;
@property (nonatomic, strong) NSNumber                                  *video_complete;
@property (nonatomic, strong) NSNumber                                  *retry;
@property (nonatomic, strong) NSString                                  *retry_error;
@property (nonatomic, strong) NSNumber                                  *generated_at; // Nanoseconds
// User info
@property (nonatomic, strong) NSNumber                                  *age;
@property (nonatomic, strong) NSString                                  *education;
@property (nonatomic, strong) NSArray<NSString*>                        *interests;
@property (nonatomic, strong) NSString                                  *gender;
@property (nonatomic, strong) NSArray<NSString*>                        *keywords;
@property (nonatomic, strong) NSNumber                                  *iap; // In app purchase enabled, Just open it for the user to fill
@property (nonatomic, strong) NSNumber                                  *iap_total; // In app purchase total spent, just open for the user to fill

- (instancetype)initWithTargeting:(PubnativeAdTargetingModel*)targeting;
- (void)addUnreachableNetworkWithNetworkCode:(NSString*)networkCode;
- (void)addAttemptedNetworkWithNetworkCode:(NSString*)networkCode;
- (void)addNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime crashModel:(PubnativeInsightCrashModel*)crashModel;
- (void)fillWithDefaults;

@end