//
//  FacebookNativeAdModel.h
//  sdk
//
//  Created by Mohit on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNAdModel.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FacebookNativeAdModel : PNAdModel

- (instancetype)initWithNativeAd:(FBNativeAd*)nativeAd;

@end
