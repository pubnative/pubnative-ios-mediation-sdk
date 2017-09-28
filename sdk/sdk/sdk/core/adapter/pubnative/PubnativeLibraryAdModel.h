//
//  PubnativeLibraryAdModel.h
//  sdk
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNAdModel.h"
#import "PNAPIAdModel.h"

@interface PubnativeLibraryAdModel : PNAdModel

- (instancetype)initWithNativeAd:(PNAPIAdModel*)model;

@end
