//
//  PNSmallLayout.h
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayout+Internal.h"
#import "PNSmallLayoutViewController.h"

@interface PNSmallLayout : PNLayout

@property (nonatomic, readonly) PNSmallLayoutViewController *viewController;

- (void)startTrackingView;
- (void)stopTrackingView;

@end
