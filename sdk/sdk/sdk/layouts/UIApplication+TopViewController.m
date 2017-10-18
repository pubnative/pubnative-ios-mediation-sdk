//
//  UIApplication+TopViewController.m
//  sdk
//
//  Created by Can Soykarafakili on 31.08.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "UIApplication+TopViewController.h"

@implementation UIApplication (TopViewController)

- (UIViewController *)topViewController
{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = tabController.selectedViewController;
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
