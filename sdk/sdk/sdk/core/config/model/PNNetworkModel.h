//
//  PNNetworkModel.h
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"

@interface PNNetworkModel : PNJSONModel

@property (nonatomic, strong) NSDictionary  *params;
@property (nonatomic, strong) NSString      *adapter;
@property (nonatomic, strong) NSNumber      *timeout;
@property (nonatomic, strong) NSNumber      *crash_report;
@property (nonatomic, strong) NSNumber      *cpa_cache;

// Accessors
@property (nonatomic, readonly) NSUInteger  timeoutInSeconds;
@property (nonatomic, readonly) BOOL        isCrashReportEnabled;
@property (nonatomic, readonly) BOOL        isCPACacheEnabled;

@end
