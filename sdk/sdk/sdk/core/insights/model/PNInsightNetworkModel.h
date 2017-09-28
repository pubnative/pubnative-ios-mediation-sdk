//
//  PNInsightNetworkModel.h
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"
#import "PNInsightCrashModel.h"

@interface PNInsightNetworkModel : PNJSONModel

@property (nonatomic, strong) NSString                  *code;
@property (nonatomic, strong) NSNumber                  *priority_rule_id;
@property (nonatomic, strong) NSArray<NSNumber*>        *priority_segment_ids;
@property (nonatomic, strong) NSNumber                  *response_time;
@property (nonatomic, strong) PNInsightCrashModel    *crash_report;

@end
