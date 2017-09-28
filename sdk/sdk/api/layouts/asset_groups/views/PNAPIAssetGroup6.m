//
//  PNAPIAssetGroup6.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup6.h"

@interface PNAPIAssetGroup6 ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *adText;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIImageView *banner;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *cta;
@property (weak, nonatomic) IBOutlet UILabel *body;

@end

@implementation PNAPIAssetGroup6

- (void)load
{
    self.adTitle.text = self.model.title;
    self.body.text = self.model.body;
    self.cta.layer.cornerRadius = kPNCTACornerRadius;
    [self.cta setTitle:self.model.callToAction forState:UIControlStateNormal];
    self.icon.layer.cornerRadius = kPNCTACornerRadius;
    
    __block NSURL *iconURL = [NSURL URLWithString:self.model.iconUrl];
    __block NSURL *bannerURL = [NSURL URLWithString:self.model.bannerUrl];
    __block PNAPIAssetGroup6 *strongSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSData *iconData = [NSData dataWithContentsOfURL:iconURL];
        __block NSData *bannerData = [NSData dataWithContentsOfURL:bannerURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (iconData == nil || bannerData == nil) {
                [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get data"
                                                               code:0
                                                           userInfo:nil]];
            } else  {
                UIImage *iconImage = [UIImage imageWithData:iconData];
                UIImage *bannerImage = [UIImage imageWithData:bannerData];
                
                if(iconImage == nil) {
                    [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get icon image"
                                                                   code:0
                                                               userInfo:nil]];
                } else if(bannerImage == nil) {
                    [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get banner image"
                                                                   code:0
                                                               userInfo:nil]];
                } else {
                    strongSelf.icon.image = iconImage;
                    strongSelf.banner.image = bannerImage;
                    [strongSelf invokeLoadFinish];
                }
            }
            strongSelf = nil;
            iconData = nil;
            bannerData = nil;
        });
        iconURL = nil;
        bannerURL = nil;
    });
}

- (void)startTracking
{
    [self.model setDelegate:self];
    [self.model startTrackingView:self.view];
}

- (void)stopTracking
{
    [self.model stopTracking];
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
