//
//  PubnativeInsightApiResponseModel.m
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightApiResponseModel.h"

NSString * const kPubnativeInsightApiResponseModelStatusSuccess = @"ok";
NSString * const kPubnativeInsightApiResponseModelStatusError   = @"error";

@implementation PubnativeInsightApiResponseModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
{
    self = [super initWithDictionary:dictionary];
    
    if(self) {
        self.status = dictionary[@"status"];
        self.error_message = dictionary[@"error_message"];
    }
    return self;
}

- (BOOL)isSuccess
{
    return [kPubnativeInsightApiResponseModelStatusSuccess isEqualToString:[self.status lowercaseString]];
}

@end
