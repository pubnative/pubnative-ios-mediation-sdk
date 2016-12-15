//
//  PubnativePlacementModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativePlacementModel.h"

@implementation PubnativePlacementModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.ad_format_code = dictionary[@"ad_format_code"];
        self.priority_rules = [PubnativePriorityRuleModel parseArrayValues:dictionary[@"priority_rules"]];
        self.delivery_rule = [PubnativeDeliveryRuleModel modelWithDictionary:dictionary[@"delivery_rule"]];
    }
    return self;
}

- (PubnativePriorityRuleModel*)priorityRuleWithIndex:(NSInteger)index
{
    PubnativePriorityRuleModel *result = nil;
    if(self.priority_rules && index < self.priority_rules.count){
        result = self.priority_rules[index];
    }
    return result;
}

@end
