//
//  PNMediumLayout.h
//  sdk
//
//  Created by Can Soykarafakili on 23.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayout+Internal.h"
#import "PNMediumLayoutViewController.h"

@interface PNMediumLayout : PNLayout

@property (nonatomic, readonly) PNMediumLayoutViewController * viewController;

- (void)startTrackingView;
- (void)stopTrackingView;

@end
