//
//  PNAPILayoutViewController.h
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLayoutViewController.h"

@class PNAPILayoutViewController;

@protocol PNAPILayoutViewControllerDelegate <NSObject>

- (void)layoutViewDidConfirmImpression:(PNAPILayoutViewController*)view;
- (void)layoutViewDidClick:(PNAPILayoutViewController*)view;

@end

@interface PNAPILayoutViewController : PNLayoutViewController

@property (nonatomic, strong)NSObject<PNAPILayoutViewControllerDelegate> *viewDelegate;

- (void)startTracking;
- (void)stopTracking;

@end
