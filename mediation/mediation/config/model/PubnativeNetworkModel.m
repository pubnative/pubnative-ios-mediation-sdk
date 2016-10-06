//
//  PubnativeNetworkModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkModel.h"

@implementation PubnativeNetworkModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.params = dictionary[@"params"];
        self.adapter = dictionary[@"adapter"];
        self.timeout = dictionary[@"timeout"];
        self.crash_report = dictionary[@"crash_report"];
    }
    return self;
}

- (BOOL)isCrashReportEnabled
{
    BOOL result = NO;
    if(self.crash_report){
        result = [self.crash_report boolValue];
    }
    return result;
}

@end
