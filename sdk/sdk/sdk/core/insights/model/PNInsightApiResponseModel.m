//
//  PNInsightApiResponseModel.m
//  sdk
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNInsightApiResponseModel.h"

NSString * const kPNInsightApiResponseModelStatusSuccess = @"ok";
NSString * const kPNInsightApiResponseModelStatusError   = @"error";

@implementation PNInsightApiResponseModel

- (void)dealloc
{
    self.status = nil;
    self.error_message = nil;
}

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
    return [kPNInsightApiResponseModelStatusSuccess isEqualToString:[self.status lowercaseString]];
}

@end
