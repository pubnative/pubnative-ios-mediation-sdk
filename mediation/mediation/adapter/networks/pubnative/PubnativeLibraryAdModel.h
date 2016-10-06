//
//  PubnativeLibraryAdModel.h
//  mediation
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"
#import "PNNativeAdModel.h"

@interface PubnativeLibraryAdModel : PubnativeAdModel

- (instancetype)initWithNativeAd:(PNNativeAdModel*)model;

@end
