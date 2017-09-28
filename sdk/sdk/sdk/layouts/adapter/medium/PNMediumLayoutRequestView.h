//
//  PNMediumLayoutRequestView.h
//  sdk
//
//  Created by Can Soykarafakili on 27.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PubNative/PubNative.h> 
#import "PNMediumLayoutViewController.h"
#import "PNMediumLayout.h"
#import "PNAdModel.h"


@interface PNMediumLayoutRequestView : PNMediumLayoutViewController

- (void)loadWithAd:(PNAdModel *)nativeAd;

@end
