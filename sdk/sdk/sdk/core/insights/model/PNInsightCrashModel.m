//
//  PNInsightCrashModel.m
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNInsightCrashModel.h"

NSString * const kPNInsightCrashModelErrorNoFill     = @"no_fill";
NSString * const kPNInsightCrashModelErrorTimeout    = @"timeout";
NSString * const kPNInsightCrashModelErrorConfig     = @"configuration";
NSString * const kPNInsightCrashModelErrorAdapter    = @"adapter";

@implementation PNInsightCrashModel

- (void)dealloc
{
    self.error = nil;
    self.details = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.error = dictionary[@"error"];
        self.details = dictionary[@"details"];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"error"] = self.error;
    result[@"details"] = self.details;
    return result;
}

@end
