//
//  PNInsightDataModel.h
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"
#import "PNInsightNetworkModel.h"
#import "PNPriorityRuleModel.h"

@interface PNInsightDataModel : PNJSONModel

//// Tracking info
@property (nonatomic, strong) NSString                          *network;
@property (nonatomic, strong) NSArray<NSString*>                *attempted_networks;
@property (nonatomic, strong) NSArray<NSString*>                *unreachable_networks;
@property (nonatomic, strong) NSArray<NSNumber*>                *delivery_segment_ids;
@property (nonatomic, strong) NSArray<PNInsightNetworkModel*>   *networks;
@property (nonatomic, strong) NSString                          *placement_name;
@property (nonatomic, strong) NSString                          *ad_format_code;
@property (nonatomic, strong) NSString                          *creative_url; // Creative selected from the ad_format_code value of the config
@property (nonatomic, strong) NSNumber                          *video_start;
@property (nonatomic, strong) NSNumber                          *video_complete;
@property (nonatomic, strong) NSNumber                          *retry;
@property (nonatomic, strong) NSString                          *retry_error;
@property (nonatomic, strong) NSNumber                          *generated_at; // Nanoseconds

- (void)addUnreachableNetworkWithNetworkCode:(NSString*)networkCode;
- (void)addAttemptedNetworkWithNetworkCode:(NSString*)networkCode;
- (void)addNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel
                           responseTime:(NSTimeInterval)responseTime
                             crashModel:(PNInsightCrashModel*)crashModel;

@end
