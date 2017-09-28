//
//  FlurryNativeAdModel.h
//  sdk
//
//  Created by Alvarlega on 04/07/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNAdModel.h"
#import "FlurryAdNative.h"

@interface FlurryNativeAdModel : PNAdModel

- (instancetype)initWithNativeAd:(FlurryAdNative*)nativeAd;

@end
