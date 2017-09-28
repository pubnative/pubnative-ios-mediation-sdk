//
//  PNAPIAssetGroup17.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup17.h"

@interface PNAPIAssetGroup17 ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *adText;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIImageView *banner;
@property (weak, nonatomic) IBOutlet UIButton *cta;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (strong, nonatomic) NSData *bannerData;
@property (strong, nonatomic) NSData *iconData;

@end

@implementation PNAPIAssetGroup17

- (void)load
{
    self.adTitle.text = self.model.title;
    self.body.text = self.model.body;
    self.cta.layer.cornerRadius = kPNCTACornerRadius;
    [self.cta setTitle:self.model.callToAction forState:UIControlStateNormal];
    self.icon.layer.cornerRadius = kPNCTACornerRadius;
    
    if (self.bannerData && self.iconData) {
        [self continueLoadingWithBannerData:self.bannerData andWithIconData:self.iconData];
    } else {
        [self loadBannerDataAndIconData];
    }
}

- (void)loadBannerDataAndIconData
{
    __block PNAPIAssetGroup17 *strongSelf = self;
    __block NSURL *bannerURL = [NSURL URLWithString:self.model.bannerUrl];
    __block NSURL *iconURL = [NSURL URLWithString:self.model.iconUrl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        strongSelf.bannerData = [NSData dataWithContentsOfURL:bannerURL];
        strongSelf.iconData = [NSData dataWithContentsOfURL:iconURL];
        [self continueLoadingWithBannerData:strongSelf.bannerData andWithIconData:strongSelf.iconData];
        bannerURL = nil;
        iconURL = nil;
        strongSelf = nil;
    });
}

- (void)continueLoadingWithBannerData:(NSData *)bannerData andWithIconData:(NSData *)iconData
{
    __block PNAPIAssetGroup17 *strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *bannerImage = [UIImage imageWithData:bannerData];
        UIImage *iconImage = [UIImage imageWithData:iconData];
        if(bannerImage == nil) {
            [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get banner image"
                                                           code:0
                                                       userInfo:nil]];
        } else if(iconImage == nil) {
            [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get icon image"
                                                           code:0
                                                       userInfo:nil]];
        } else {
            strongSelf.banner.image = bannerImage;
            strongSelf.icon.image = iconImage;
            [strongSelf invokeLoadFinish];
        }
        strongSelf = nil;
    });
}

- (void)dealloc
{
    self.bannerData = nil;
    self.iconData = nil;
}

#pragma mark - PNLayoutViewController -

- (void)adBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

- (void)titleTextColor:(UIColor *)color
{
    self.adTitle.textColor = color;
}

- (void)titleFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.adTitle setFont:[UIFont fontWithName:fontName size:size]];
}

- (void)descriptionTextColor:(UIColor *)color
{
    self.body.textColor = color;
}

- (void)descriptionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.body setFont:[UIFont fontWithName:fontName size:size]];
}

- (void)callToActionBackgroundColor:(UIColor *)color
{
    self.cta.backgroundColor = color;
}

- (void)callToActionTextColor:(UIColor *)color
{
    [self.cta setTitleColor:color forState:UIControlStateNormal];
}

- (void)callToActionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.cta.titleLabel setFont:[UIFont fontWithName:fontName size:size]];
}

@end
