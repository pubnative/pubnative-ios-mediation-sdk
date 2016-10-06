//
//  PubnativeInsightModel.h
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeInsightDataModel.h"
#import "PubnativeInsightsManager.h"
#import "PubnativePriorityRuleModel.h"

@interface PubnativeInsightModel : NSObject

@property (nonatomic, strong) NSString                          *requestInsightUrl;
@property (nonatomic, strong) NSString                          *impressionInsightUrl;
@property (nonatomic, strong) NSString                          *clickInsightUrl;
@property (nonatomic, strong) NSString                          *placementName;
@property (nonatomic, strong) NSString                          *appToken;
@property (nonatomic, strong) PubnativeInsightDataModel         *data;

@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *params;

- (void)sendRequestInsight;
- (void)sendImpressionInsight;
- (void)sendClickInsight;
- (void)trackUnreachableNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime error:(NSError*)error;
- (void)trackAttemptedNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime error:(NSError*)error;
- (void)trackSuccededNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime;

@end
