//
//  PNLargeLibraryAdapterViewController.h
//  sdk
//
//  Created by Can Soykarafakili on 04.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAPILayoutViewController.h"
#import "PNLargeLayout.h"
#import "PNLargeLayoutContainerViewController.h"

@interface PNLargeLibraryAdapterViewController : PNLargeLayoutContainerViewController

- (instancetype)initWithViewController:(PNAPILayoutViewController *)layout;

@end
