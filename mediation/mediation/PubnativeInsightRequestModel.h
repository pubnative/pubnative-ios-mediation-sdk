//
//  PubnativeInsightRequestModel.h
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "PubnativeInsightsManager.h"
#import "PubnativeInsightDataModel.h"

@interface PubnativeInsightRequestModel : NSObject

@property (nonatomic, strong) NSString                              *url;
@property (nonatomic, strong) PubnativeInsightDataModel             *data;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>    *params;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)toDictionary;

@end
