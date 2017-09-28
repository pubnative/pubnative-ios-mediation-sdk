//
//  PNNetworkModel.m
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNNetworkModel.h"

@implementation PNNetworkModel

- (void)dealloc
{
    self.params = nil;
    self.adapter = nil;
    self.timeout = nil;
    self.crash_report = nil;
    self.cpa_cache = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.params = dictionary[@"params"];
        self.adapter = dictionary[@"adapter"];
        self.timeout = dictionary[@"timeout"];
        self.crash_report = dictionary[@"crash_report"];
        self.cpa_cache = dictionary[@"cpa_cache"];
    }
    return self;
}

- (NSUInteger)timeoutInSeconds
{
    NSUInteger result = 0;
    if(self.timeout != nil) {
        result = [self.timeout unsignedIntegerValue] / 1000;
    }
    return result;
}

- (BOOL)isCrashReportEnabled
{
    BOOL result = NO;
    if(self.crash_report){
        result = [self.crash_report boolValue];
    }
    return result;
}

- (BOOL)isCPACacheEnabled
{
    BOOL result = NO;
    if(self.cpa_cache){
        result = [self.cpa_cache boolValue];
    }
    return result;
}

@end
