//
//  PNOrientationManager.m
//  sdk
//
//  Created by Can Soykarafakili on 21.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNOrientationManager.h"

NSString * const kPNOrientationManagerDidChangeOrientation = @"PNOrientationManagerDidChangeOrientation";

@interface PNOrientationManager ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation PNOrientationManager

+ (void)load
{
    [[PNOrientationManager sharedInstance] startListening];
}

+ (instancetype)sharedInstance
{
    static PNOrientationManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PNOrientationManager alloc] init];
    });
    return _sharedInstance;
}

+ (UIInterfaceOrientation)orientation
{
    if([PNOrientationManager sharedInstance].orientation == UIInterfaceOrientationUnknown) {
        [PNOrientationManager sharedInstance].orientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return [PNOrientationManager sharedInstance].orientation;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.orientation = UIInterfaceOrientationUnknown;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startListening
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification
{
    if ([PNOrientationManager sharedInstance].orientation != [UIApplication sharedApplication].statusBarOrientation) {
        [PNOrientationManager sharedInstance].orientation = [UIApplication sharedApplication].statusBarOrientation;
        [self sendDidChangeOrientationNotication];
    }
}

- (void)sendDidChangeOrientationNotication
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPNOrientationManagerDidChangeOrientation
                                                        object:nil];
}

@end
