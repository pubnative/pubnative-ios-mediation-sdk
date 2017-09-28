//
//  PNConfigAPIResponseModel.m
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNConfigAPIResponseModel.h"

NSString * const kPNAPIStatusSuccessValue    = @"ok";
NSString * const kPNAPIStatusErrorValue      = @"error";

@implementation PNConfigAPIResponseModel

- (void)dealloc
{
    self.status = nil;
    self.error_message = nil;
    self.config = nil;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
{
    self = [super initWithDictionary:dictionary];
    
    if(self) {
        self.status = dictionary[@"status"];
        self.error_message = dictionary[@"error_message"];
        self.config = [PNConfigModel modelWithDictionary:dictionary[@"config"]];
    }
    return self;
}

- (BOOL)isSuccess
{
    return [kPNAPIStatusSuccessValue isEqualToString:[self.status lowercaseString]];
}

@end
