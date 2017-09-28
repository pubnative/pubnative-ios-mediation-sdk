//
//  PubnativePriorityRulesModel.m
//  sdk
//
//  Created by Mohit on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNPriorityRuleModel.h"

@implementation PNPriorityRuleModel

- (void)dealloc
{
    self.identifier = nil;
    self.network_code = nil;
    self.params = nil;
    self.segment_ids = nil;
}

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
