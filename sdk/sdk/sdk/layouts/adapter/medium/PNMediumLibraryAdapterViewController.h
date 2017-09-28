//
//  PNMediumLibraryAdapterViewController.h
//  sdk
//
//  Created by Can Soykarafakili on 23.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAPILayoutViewController.h"
#import "PNMediumLayout.h"
#import "PNMediumLayoutContainerViewController.h"

@interface PNMediumLibraryAdapterViewController : PNMediumLayoutContainerViewController

- (instancetype)initWithViewController:(PNAPILayoutViewController *)layout;

@end
