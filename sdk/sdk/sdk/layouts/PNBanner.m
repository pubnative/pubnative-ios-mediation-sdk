//
//  PNBanner.m
//  sdk
//
//  Created by Can Soykarafakili on 15.08.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNBanner.h"

@interface PNBanner ()

@property (nonatomic, strong) UIView *bannerContainer;
@property (readonly) UIViewController *containerViewController;
@property (readonly) NSLayoutConstraint *topConstraint;
@property (readonly) NSLayoutConstraint *bottomConstraint;
@property (readonly) NSLayoutConstraint *widthConstraint;
@property (readonly) NSLayoutConstraint *heightConstraint;
@property (readonly) NSLayoutConstraint *centerConstraint;
@property (nonatomic, assign) BOOL shown;

@end

@implementation PNBanner

-(void)dealloc
{
    self.bannerContainer = nil;
}

- (void)showWithPosition:(PNBannerPosition)position
{
    if (self.shown) {
        NSLog(@"The banner is already shown, dropping this call");
    } else {
        if (self.bannerContainer == nil) {
            self.bannerContainer = [[UIView alloc] init];
        }
        [self.bannerContainer addSubview:self.viewController.view];
        [self startTrackingView];
        [self.containerViewController.view addSubview:self.bannerContainer];
        [self.containerViewController.view bringSubviewToFront:self.bannerContainer];
        self.bannerContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self setAdContainerPosition:position];
        self.shown = YES;
    }
    
}

- (UIViewController *)containerViewController
{
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)setAdContainerPosition:(PNBannerPosition)position
{
    [self.bannerContainer addConstraints:@[self.widthConstraint, self.heightConstraint]];
    
    switch (position) {
        case BANNER_POSITION_TOP:
            [self.containerViewController.view addConstraints:@[self.centerConstraint, self.topConstraint]];
            break;
        case BANNER_POSITION_BOTTOM:
            [self.containerViewController.view addConstraints:@[self.centerConstraint, self.bottomConstraint]];
            break;
    }
}

- (NSLayoutConstraint *)widthConstraint
{
    return [NSLayoutConstraint constraintWithItem:self.bannerContainer
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:0
                                       multiplier:1.0
                                         constant:self.viewController.view.frame.size.width];
}

- (NSLayoutConstraint *)heightConstraint
{
    return [NSLayoutConstraint constraintWithItem:self.bannerContainer
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:0
                                       multiplier:1.0
                                         constant:self.viewController.view.frame.size.height];
}

- (NSLayoutConstraint *)centerConstraint
{
    return [NSLayoutConstraint constraintWithItem:self.containerViewController.view
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.bannerContainer
                                        attribute:NSLayoutAttributeCenterX
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)topConstraint
{
    return [NSLayoutConstraint constraintWithItem:self.containerViewController.view
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.bannerContainer
                                        attribute:NSLayoutAttributeTop
                                       multiplier:1.0
                                         constant:0.0f];
}

- (NSLayoutConstraint *)bottomConstraint
{
    return [NSLayoutConstraint constraintWithItem:self.containerViewController.view
                                        attribute:NSLayoutAttributeBottom
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.bannerContainer
                                        attribute:NSLayoutAttributeBottom
                                       multiplier:1.0
                                         constant:0.0f];
}

- (void)hide
{
    if (self.shown) {
        [self stopTrackingView];
        [self.bannerContainer removeFromSuperview];
        self.shown = NO;
    }
}

@end
