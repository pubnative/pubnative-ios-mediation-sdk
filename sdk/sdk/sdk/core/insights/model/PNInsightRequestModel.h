//
//  PNInsightRequestModel.h
//  sdk
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "PNInsightsManager.h"
#import "PNInsightDataModel.h"

@interface PNInsightRequestModel : NSObject

@property (nonatomic, strong) NSString                              *url;
@property (nonatomic, strong) PNInsightDataModel                 *data;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>    *params;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)toDictionary;

@end
