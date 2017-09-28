//
//  PNLargeLayoutContainerViewController.m
//  sdk
//
//  Created by Can Soykarafakili on 04.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLargeLayoutContainerViewController.h"

@implementation PNLargeLayoutContainerViewController

- (instancetype)initWithViewController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        UIView *view = [currentBundle loadNibNamed:@"PNLargeLayoutContainerViewController"
                                             owner:self
                                           options:nil][0];
        super.view = view;
        [self addSubview:controller.view];
        [self addChildViewController:controller];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)addSubview:(UIView *)view
{
    [self.view addSubview:view];
    view.center = view.superview.center;
    view.frame = view.superview.frame;
}

- (void)containerBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

@end
