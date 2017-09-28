//
//  PNInsightModel.m
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNInsightModel.h"
#import "PNInsightCrashModel.h"

@implementation PNInsightModel

- (void)dealloc
{
    self.requestInsightUrl = nil;
    self.impressionInsightUrl = nil;
    self.clickInsightUrl = nil;
    self.placementName = nil;
    self.appToken = nil;
    self.data = nil;
    self.params = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [[PNInsightDataModel alloc] init];
    }
    return self;
}

- (void)sendRequestInsight
{
    [PNInsightsManager trackDataWithUrl:self.requestInsightUrl parameters:self.params data:self.data];
}

- (void)sendImpressionInsight
{
    [PNInsightsManager trackDataWithUrl:self.impressionInsightUrl parameters:self.params data:self.data];
}

- (void)sendClickInsight
{
    [PNInsightsManager trackDataWithUrl:self.clickInsightUrl parameters:self.params data:self.data];
}

- (void)trackUnreachableNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel
                                        responseTime:(NSTimeInterval)responseTime
                                           error:(NSError*)error
{
    PNInsightCrashModel *crashModel = [[PNInsightCrashModel alloc] init];
    crashModel.error = error.domain;
    crashModel.details = error.description;
    [self.data addUnreachableNetworkWithNetworkCode:priorityRuleModel.network_code];
    [self.data addNetworkWithPriorityRuleModel:priorityRuleModel responseTime:responseTime crashModel:crashModel];
}

- (void)trackAttemptedNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel
                                      responseTime:(NSTimeInterval)responseTime
                                             error:(NSError*)error
{
    PNInsightCrashModel *crashModel = [[PNInsightCrashModel alloc] init];
    crashModel.error = error.domain;
    crashModel.details = error.description;
    [self.data addAttemptedNetworkWithNetworkCode:priorityRuleModel.network_code];
    [self.data addNetworkWithPriorityRuleModel:priorityRuleModel responseTime:responseTime crashModel:crashModel];
}

- (void)trackSuccededNetworkWithPriorityRuleModel:(PNPriorityRuleModel*)priorityRuleModel
                                     responseTime:(NSTimeInterval)responseTime
{
    self.data.network = priorityRuleModel.network_code;
    [self.data addNetworkWithPriorityRuleModel:priorityRuleModel responseTime:responseTime crashModel:nil];
}

@end
