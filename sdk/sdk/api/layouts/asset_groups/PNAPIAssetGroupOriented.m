//
//  PNAPIAssetGroupOriented.m
//  sdk
//
//  Created by Can Soykarafakili on 29.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroupOriented.h"
#import "PNOrientationManager.h"

@implementation PNAPIAssetGroupOriented

- (instancetype)init
{
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeOrientation:)
                                                     name:kPNOrientationManagerDidChangeOrientation
                                                   object:nil];
        [self addOrientedView];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addOrientedView
{
    self.view = [self orientedView];
}

- (void)didChangeOrientation:(NSNotification *)notification
{
    [self addOrientedView];
    [self load];
}

- (UIView*)orientedView
{
    return [[NSBundle bundleForClass:[self class]] loadNibNamed:[self orientedNibName]
                                                          owner:self
                                                        options:nil][0];
}

- (NSString*)orientedNibName
{
    NSString *result = NSStringFromClass([self class]);
    if (UIInterfaceOrientationIsLandscape([PNOrientationManager orientation]))  {
        result = [result stringByAppendingString:@"Landscape"];
    }
    return result;
}

@end
