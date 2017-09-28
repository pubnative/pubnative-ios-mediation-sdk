//
//  PNInsightRequestModel.m
//  sdk
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNInsightRequestModel.h"

NSString * const kPNInsightRequestModelUrlKey         = @"url";
NSString * const kPNInsightRequestModelParametersKey  = @"parameters";
NSString * const kPNInsightRequestModelDataKey        = @"data";

@implementation PNInsightRequestModel


- (void)dealloc
{
    self.url = nil;
    self.data = nil;
    self.params = nil;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.url = dictionary[kPNInsightRequestModelUrlKey];
        self.params = dictionary[kPNInsightRequestModelParametersKey];
        self.data = [PNInsightDataModel modelWithDictionary:dictionary[kPNInsightRequestModelDataKey]];
    }
    return self;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[kPNInsightRequestModelUrlKey] = self.url;
    result[kPNInsightRequestModelParametersKey] = self.params;
    result[kPNInsightRequestModelDataKey] = [self.data toDictionary];
    
    return result;
}

@end
