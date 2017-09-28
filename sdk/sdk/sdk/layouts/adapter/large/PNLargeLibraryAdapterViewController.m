//
//  PNLargeLibraryAdapterViewController.m
//  sdk
//
//  Created by Can Soykarafakili on 04.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLargeLibraryAdapterViewController.h"

@interface PNLargeLibraryAdapterViewController ()

@property (nonatomic, strong) PNAPILayoutViewController *layout;

@end

@implementation PNLargeLibraryAdapterViewController

- (instancetype)initWithViewController:(PNAPILayoutViewController *)layout
{
    self = [super initWithViewController:layout];
    if (self) {
        self.layout = layout;
    }
    return self;
}

- (void)dealloc
{
    [self.layout.view removeFromSuperview];
    self.layout = nil;
}

- (void)adBackgroundColor:(UIColor *)color
{
    [self.layout adBackgroundColor:color];
}

#pragma mark - Title -

- (void)titleTextColor:(UIColor *)color
{
    [self.layout titleTextColor:color];
}

- (void)titleFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.layout titleFontWithName:fontName size:size];
}

#pragma mark - Description -

- (void)descriptionTextColor:(UIColor *)color
{
    [self.layout descriptionTextColor:color];
}

- (void)descriptionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.layout descriptionFontWithName:fontName size:size];
}

#pragma mark - Call To Action -

- (void)callToActionBackgroundColor:(UIColor *)color
{
    [self.layout callToActionBackgroundColor:color];
}

- (void)callToActionTextColor:(UIColor *)color
{
    [self.layout callToActionTextColor:color];
}

- (void)callToActionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.layout callToActionFontWithName:fontName size:size];
}

@end
