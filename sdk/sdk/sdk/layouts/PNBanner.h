//
//  PNBanner.h
//  sdk
//
//  Created by Can Soykarafakili on 15.08.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNSmallLayout.h"

typedef enum : NSUInteger {
    BANNER_POSITION_TOP,
    BANNER_POSITION_BOTTOM,
} PNBannerPosition;

@interface PNBanner : PNSmallLayout

- (void)showWithPosition:(PNBannerPosition)position;
- (void)hide;

@end
