//
//  PNInsightCrashModel.h
//  sdk
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"

extern NSString * const kPNInsightCrashModelErrorNoFill;
extern NSString * const kPNInsightCrashModelErrorTimeout;
extern NSString * const kPNInsightCrashModelErrorConfig;
extern NSString * const kPNInsightCrashModelErrorAdapter;

@interface PNInsightCrashModel : PNJSONModel

@property (nonatomic, strong) NSString  *error;
@property (nonatomic, strong) NSString  *details;

@end
