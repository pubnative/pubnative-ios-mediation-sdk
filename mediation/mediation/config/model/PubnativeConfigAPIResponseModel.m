//
//  PubnativeConfigAPIResponseModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigAPIResponseModel.h"

NSString * const kAPIStatusSuccessValue         = @"ok";
NSString * const kAPIStatusErrorValue           = @"error";

@implementation PubnativeConfigAPIResponseModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
{
    self = [super initWithDictionary:dictionary];
    
    if(self) {
        self.status = dictionary[@"status"];
        self.error_message = dictionary[@"error_message"];
        self.config = [PubnativeConfigModel modelWithDictionary:dictionary[@"config"]];
    }
    return self;
}

- (BOOL)isSuccess
{
    return [kAPIStatusSuccessValue isEqualToString:[self.status lowercaseString]];
}

@end
