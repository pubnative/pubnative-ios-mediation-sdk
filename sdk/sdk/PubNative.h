//
//  sdk_framework.h
//  sdk.framework
//
//  Created by David Martin on 08/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Pubnative.framework.
FOUNDATION_EXPORT double PubnativeVersionNumber;

//! Project version string for Pubnative.framework.
FOUNDATION_EXPORT const unsigned char PubnativeVersionString[];

#import <Pubnative/PNRequest.h>
#import <Pubnative/PNAdModel.h>
#import <Pubnative/PNAdTargetingModel.h>
#import <Pubnative/PNConfigManager.h>
#import <Pubnative/PNSmallLayout.h>
#import <Pubnative/PNMediumLayout.h>
#import <Pubnative/PNLargeLayout.h>
#import <Pubnative/PNAPILayout.h>
#import <Pubnative/PNAdModelRenderer.h>
#import <Pubnative/PNAPIRequestParameter.h>
#import <Pubnative/PNBanner.h>
#import <Pubnative/PNAdModel+Native.h>

@interface Pubnative : NSObject

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(PNAdTargetingModel*)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString*)appToken;

@end
