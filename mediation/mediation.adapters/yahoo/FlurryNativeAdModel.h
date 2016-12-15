//
//  FlurryNativeAdModel.h
//  mediation
//
//  Created by Alvarlega on 04/07/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"
#import "FlurryAdNative.h"

@interface FlurryNativeAdModel : PubnativeAdModel

- (instancetype)initWithNativeAd:(FlurryAdNative*)nativeAd;

@end
