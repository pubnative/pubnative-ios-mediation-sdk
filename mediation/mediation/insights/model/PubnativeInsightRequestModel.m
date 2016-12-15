//
//  PubnativeInsightRequestModel.m
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightRequestModel.h"

NSString * const kInsightRequestModelUrlKey         = @"url";
NSString * const kInsightRequestModelParametersKey  = @"parameters";
NSString * const kInsightRequestModelDataKey        = @"data";

@implementation PubnativeInsightRequestModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.url = dictionary[kInsightRequestModelUrlKey];
        self.params = dictionary[kInsightRequestModelParametersKey];
        self.data = [PubnativeInsightDataModel modelWithDictionary:dictionary[kInsightRequestModelDataKey]];
    }
    return self;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[kInsightRequestModelUrlKey] = self.url;
    result[kInsightRequestModelParametersKey] = self.params;
    result[kInsightRequestModelDataKey] = [self.data toDictionary];
    
    return result;
}

@end