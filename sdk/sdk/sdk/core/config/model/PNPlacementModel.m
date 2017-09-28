//
//  PNPlacementModel.m
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNPlacementModel.h"

@implementation PNPlacementModel

- (void)dealloc
{
    self.ad_format_code = nil;
    self.priority_rules = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.ad_format_code = dictionary[@"ad_format_code"];
        self.priority_rules = [PNPriorityRuleModel parseArrayValues:dictionary[@"priority_rules"]];
    }
    return self;
}

- (PNPriorityRuleModel*)priorityRuleWithIndex:(NSInteger)index
{
    PNPriorityRuleModel *result = nil;
    if(self.priority_rules && index < self.priority_rules.count){
        result = self.priority_rules[index];
    }
    return result;
}

@end
