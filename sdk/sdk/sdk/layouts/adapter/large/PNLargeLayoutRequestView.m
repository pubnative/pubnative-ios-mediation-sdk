//
//  PNLargeLayoutRequestView.m
//  sdk
//
//  Created by Can Soykarafakili on 05.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLargeLayoutRequestView.h"

@interface PNLargeLayoutRequestView ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *descriptionLabel;
@property (nonatomic, weak) UIImageView *icon;
@property (nonatomic, weak) UIButton *callToAction;

@property (nonatomic, weak) UILabel *socialContext;
@property (nonatomic, weak) UIView *contentInfoView;


@end

@implementation PNLargeLayoutRequestView

- (void)loadWithAd:(PNAdModel *)nativeAd
{
    
    PNAdModelRenderer *renderer = [[PNAdModelRenderer alloc] init];
    renderer.titleView = self.titleLabel;
    renderer.iconView = self.icon;
    renderer.descriptionView = self.descriptionLabel;
    renderer.callToActionView = self.callToAction;
    
    [nativeAd renderAd:renderer];
}

- (void)adBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

#pragma mark - Title -

- (void)titleTextColor:(UIColor *)color
{
    [self.titleLabel setTextColor:color];
}
- (void)titleFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.titleLabel setFont:[UIFont fontWithName:fontName size:size]];
}

- (void)descriptionTextColor:(UIColor *)color
{
    [self.descriptionLabel setTextColor:color];
}

- (void)descriptionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.descriptionLabel setFont:[UIFont fontWithName:fontName size:size]];
}

#pragma mark - Call To Action -

- (void)callToActionBackgroundColor:(UIColor *)color
{
    [self.callToAction setBackgroundColor:color];
}

- (void)callToActionTextColor:(UIColor *)color
{
    [self.callToAction setTitleColor:color forState:UIControlStateNormal];
}

- (void)callToActionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.callToAction.titleLabel setFont:[UIFont fontWithName:fontName size:size]];
}

@end
