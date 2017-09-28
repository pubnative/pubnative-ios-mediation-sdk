//
//  PNSmallLibraryAdapterViewController.m
//  sdk
//
//  Created by Can Soykarafakili on 21.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNSmallLibraryAdapterViewController.h"

@interface PNSmallLibraryAdapterViewController ()

@property (nonatomic, strong) PNAPILayoutViewController *layout;

@end

@implementation PNSmallLibraryAdapterViewController

- (instancetype)initWithViewController:(PNAPILayoutViewController *)layout
{
    self = [super initWithView:layout.view];
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

- (void)iconWithPosition:(IconPosition)position
{
    [self.layout iconWithPosition:position];
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
