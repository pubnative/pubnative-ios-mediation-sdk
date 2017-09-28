//
//  PNMediumLayoutViewController.h
//  sdk
//
//  Created by Can Soykarafakili on 27.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayoutViewController.h"

typedef enum {
    TOP,
    CENTER,
    BOTTOM
}BannerPosition;

@interface PNMediumLayoutViewController : PNLayoutViewController

- (void)bannerWithPosition:(BannerPosition)position;

@end
