//
//  PNInsightNetworkModel.m
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNInsightNetworkModel.h"

@implementation PNInsightNetworkModel

- (void)dealloc
{
    self.code = nil;
    self.priority_rule_id = nil;
    self.priority_segment_ids = nil;
    self.response_time = nil;
    self.crash_report = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.code = dictionary[@"code"];
        self.priority_rule_id = dictionary[@"priority_rule_id"];
        self.priority_segment_ids = dictionary[@"priority_segment_ids"];
        self.response_time = dictionary[@"response_time"];
        self.crash_report = [PNInsightCrashModel modelWithDictionary:dictionary[@"crash_report"]];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"code"] = self.code;
    result[@"priority_rule_id"] = self.priority_rule_id;
    result[@"priority_segment_ids"] = self.priority_segment_ids;
    result[@"response_time"] = self.response_time;
    NSDictionary *crashDictionary = nil;
    if(self.crash_report) {
        crashDictionary = [self.crash_report toDictionary];
    }
    result[@"crash_report"] = crashDictionary;
    return result;
}

@end
