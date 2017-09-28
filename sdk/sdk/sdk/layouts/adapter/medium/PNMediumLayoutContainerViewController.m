//
//  PNMediumLayoutContainerViewController.m
//  sdk
//
//  Created by Can Soykarafakili on 23.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNMediumLayoutContainerViewController.h"

@implementation PNMediumLayoutContainerViewController

- (instancetype)initWithView:(UIView *)subView
{
    self = [super init];
    if (self) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        UIView *view = [currentBundle loadNibNamed:@"PNMediumLayoutContainerViewController"
                                             owner:self
                                           options:nil][0];
        super.view = view;
        [self addSubview:subView];
    }
    return self;
}

- (void)addSubview:(UIView *)view
{
    [self.view addSubview:view];
    view.center = view.superview.center;
}

- (void)containerBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

@end
