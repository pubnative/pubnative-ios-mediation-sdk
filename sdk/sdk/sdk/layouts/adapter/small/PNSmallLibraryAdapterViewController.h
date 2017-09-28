//
//  PNSmallLibraryAdapterViewController.h
//  sdk
//
//  Created by Can Soykarafakili on 21.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAPILayoutViewController.h"
#import "PNSmallLayout.h"
#import "PNSmallLayoutContainerViewController.h"

@interface PNSmallLibraryAdapterViewController : PNSmallLayoutContainerViewController

- (instancetype)initWithViewController:(PNAPILayoutViewController *)layout;

@end
