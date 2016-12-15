//
//  PubnativeInsightCrashModel.h
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeJSONModel.h"

extern NSString * const kPubnativeInsightCrashModelErrorNoFill;
extern NSString * const kPubnativeInsightCrashModelErrorTimeout;
extern NSString * const kPubnativeInsightCrashModelErrorConfig;
extern NSString * const kPubnativeInsightCrashModelErrorAdapter;

@interface PubnativeInsightCrashModel : PubnativeJSONModel

@property (nonatomic, strong) NSString  *error;
@property (nonatomic, strong) NSString  *details;

@end
