//
//  PubnativeAdTargetingModel.m
//  mediation
//
//  Created by Alvarlega on 28/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeAdTargetingModel.h"

NSString* const kPubnativeAdTargetingModelGenderFemale = @"f";
NSString* const kPubnativeAdTargetingModelGenderMale = @"m";

@implementation PubnativeAdTargetingModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.age = dictionary[@"age"];
        self.education = dictionary[@"education"];
        self.interests = dictionary[@"interests"];
        self.gender = dictionary[@"gender"];
        self.iap = dictionary[@"iap"];
        self.iap_total = dictionary[@"iap_total"];
    }
    return self;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[@"age"] = self.age;
    result[@"education"] = self.education;
    result[@"interests"] = self.interests;
    result[@"gender"] = self.gender;
    result[@"iap"] = self.iap;
    result[@"iap_total"] = self.iap_total;
    
    return result;
}

@end
