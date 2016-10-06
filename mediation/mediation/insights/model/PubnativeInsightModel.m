//
//  PubnativeInsightModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightModel.h"
#import "PubnativeInsightCrashModel.h"
#import "PubnativeDeliveryManager.h"

@implementation PubnativeInsightModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [[PubnativeInsightDataModel alloc] init];
    }
    return self;
}

- (void)sendRequestInsight
{
    [PubnativeInsightsManager trackDataWithUrl:self.requestInsightUrl parameters:self.params data:self.data];
}

- (void)sendImpressionInsight
{
    [PubnativeInsightsManager trackDataWithUrl:self.impressionInsightUrl parameters:self.params data:self.data];
}

- (void)sendClickInsight
{
    [PubnativeInsightsManager trackDataWithUrl:self.clickInsightUrl parameters:self.params data:self.data];
}

- (void)trackUnreachableNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel
                                        responseTime:(NSNumber*)responseTime
                                           error:(NSError*)error
{
    PubnativeInsightCrashModel *crashModel = [[PubnativeInsightCrashModel alloc] init];
    crashModel.error = error.domain;
    crashModel.details = error.description;
    [self.data addUnreachableNetworkWithNetworkCode:priorityRuleModel.network_code];
    [self.data addNetworkWithPriorityRuleModel:priorityRuleModel responseTime:responseTime crashModel:crashModel];
}

- (void)trackAttemptedNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel
                                      responseTime:(NSNumber*)responseTime
                                         error:(NSError*)error
{
    PubnativeInsightCrashModel *crashModel = [[PubnativeInsightCrashModel alloc] init];
    crashModel.error = error.domain;
    crashModel.details = error.description;
    [self.data addAttemptedNetworkWithNetworkCode:priorityRuleModel.network_code];
    [self.data addNetworkWithPriorityRuleModel:priorityRuleModel responseTime:responseTime crashModel:crashModel];
}

- (void)trackSuccededNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel
                                     responseTime:(NSNumber*)responseTime
{
    self.data.network = priorityRuleModel.network_code;
    [self.data addNetworkWithPriorityRuleModel:priorityRuleModel responseTime:responseTime crashModel:nil];
    [PubnativeDeliveryManager updatePacingDateForPlacementName:self.data.placement_name];
}

@end
