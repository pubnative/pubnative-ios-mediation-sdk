//
//  PubnativePriorityRulesModel.m
//  mediation
//
//  Created by Mohit on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativePriorityRuleModel.h"

@implementation PubnativePriorityRuleModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self) {
        self.identifier = dictionary[@"id"];
        self.network_code = dictionary[@"network_code"];
        self.params = dictionary[@"params"];
        self.segment_ids = dictionary[@"segment_ids"];
    }
    return self;
}

@end
