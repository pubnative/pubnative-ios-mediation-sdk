//
//  PubnativeInsightCrashModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightCrashModel.h"

NSString * const kPubnativeInsightCrashModelErrorNoFill     = @"no_fill";
NSString * const kPubnativeInsightCrashModelErrorTimeout    = @"timeout";
NSString * const kPubnativeInsightCrashModelErrorConfig     = @"configuration";
NSString * const kPubnativeInsightCrashModelErrorAdapter    = @"adapter";

@implementation PubnativeInsightCrashModel

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
