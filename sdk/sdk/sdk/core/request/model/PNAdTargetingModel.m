//
//  PNAdTargetingModel.m
//  sdk
//
//  Created by Alvarlega on 28/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNAdTargetingModel.h"

NSString* const kPNAdTargetingModelGenderFemale = @"f";
NSString* const kPNAdTargetingModelGenderMale = @"m";

@implementation PNAdTargetingModel

- (void)dealloc
{
    self.age = nil;
    self.education = nil;
    self.interests = nil;
    self.gender = nil;
    self.iap = nil;
    self.iap_total = nil;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[@"age"] = [self.age stringValue];
    result[@"education"] = self.education;
    result[@"interests"] = [self.interests componentsJoinedByString:@","];
    result[@"gender"] = self.gender;
    
    return result;
}

- (NSDictionary*)toDictionaryWithIAP
{
    NSMutableDictionary *result = [[self toDictionary] mutableCopy];
    
    result[@"iap"] = [self.iap stringValue];
    result[@"iap_total"] = [self.iap_total stringValue];
    
    return result;
}

@end
