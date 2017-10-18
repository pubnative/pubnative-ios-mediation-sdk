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
@property (weak, nonatomic) IBOutlet UIView *contentInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation PNAPIAssetGroup17

- (void)load
{
    self.adTitle.text = self.model.title;
    self.body.text = self.model.body;
    self.cta.layer.cornerRadius = kPNCTACornerRadius;
    [self.cta setTitle:self.model.callToAction forState:UIControlStateNormal];
    self.icon.layer.cornerRadius = kPNCTACornerRadius;
    [self.contentInfoView addSubview:self.model.contentInfo];
    
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
    __block NSData *bannerDataInBlock = bannerData;
    __block NSData *iconDataInBlock = iconData;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *bannerImage = [UIImage imageWithData:bannerDataInBlock];
        UIImage *iconImage = [UIImage imageWithData:iconDataInBlock];
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
        bannerDataInBlock = nil;
        iconDataInBlock = nil;
    });
}

- (void)updateContentInfoSize:(NSNotification *)notification
{
    NSNumber *contentInfoSize = notification.object;
    self.widthConstraint.constant = [contentInfoSize floatValue];
    [self.view layoutIfNeeded];
}

- (void)dealloc
{
    self.bannerData = nil;
    self.iconData = nil;
}


@end
