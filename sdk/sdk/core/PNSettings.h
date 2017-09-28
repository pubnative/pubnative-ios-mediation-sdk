//
//  PNSettings.h
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <CoreLocation/CoreLocation.h>
#import "PNAdTargetingModel.h"

@interface PNSettings : NSObject

@property (readonly) BOOL                needsFill;

// CONFIGURABLE PARAMETERS
@property (nonatomic, assign) BOOL            		test;
@property (nonatomic, assign) BOOL            		coppa;
@property (nonatomic, strong) PNAdTargetingModel 	*targeting;

// COMMON PARAMETERS
@property (readonly) NSString                       *advertisingId;
@property (nonatomic, strong) NSString             	*os;
@property (nonatomic, strong) NSString             	*osVersion;
@property (nonatomic, strong) NSString             	*deviceName;
@property (nonatomic, strong) NSString             	*locale;
@property (nonatomic, strong) NSString             	*sdkVersion;
@property (nonatomic, strong) NSString             	*appBundleID;
@property (nonatomic, strong) NSString             	*appVersion;
@property (readonly) CLLocation                     *location;

+ (PNSettings*)sharedInstance;
- (void)fillDefaults;

@end
