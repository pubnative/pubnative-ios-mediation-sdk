//
//  PNSmallLayoutRequestView.h
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PubNative/PubNative.h> 
#import "PNSmallLayoutViewController.h"
#import "PNSmallLayout.h"
#import "PNAdModel.h"

@interface PNSmallLayoutRequestView : PNSmallLayoutViewController

- (void)loadWithAd:(PNAdModel *)nativeAd;

@end
