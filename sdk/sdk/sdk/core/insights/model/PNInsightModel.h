//
//  PNInsightModel.h
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNInsightDataModel.h"
#import "PNInsightsManager.h"
#import "PNPriorityRuleModel.h"

@interface PNInsightModel : NSObject

@property (nonatomic, strong) NSString                          *requestInsightUrl;
@property (nonatomic, strong) NSString                          *impressionInsightUrl;
@property (nonatomic, strong) NSString                          *clickInsightUrl;
@property (nonatomic, strong) NSString                          *placementName;
@property (nonatomic, strong) NSString                          *appToken;
@property (nonatomic, strong) PNInsightDataModel             *data;
@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *params;

- (void)sendRequestInsight;
- (void)sendImpressionInsight;
- (void)sendClickInsight;
- (void)trackUnreachableNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel responseTime:(NSTimeInterval)responseTime error:(NSError*)error;
- (void)trackAttemptedNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel responseTime:(NSTimeInterval)responseTime error:(NSError*)error;
- (void)trackSuccededNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel responseTime:(NSTimeInterval)responseTime;

@end
