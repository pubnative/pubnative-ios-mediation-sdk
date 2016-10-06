//
//  FacebookNativeAdModel.h
//  mediation
//
//  Created by Mohit on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FacebookNativeAdModel : PubnativeAdModel

- (instancetype)initWithNativeAd:(FBNativeAd*)nativeAd;

@end
