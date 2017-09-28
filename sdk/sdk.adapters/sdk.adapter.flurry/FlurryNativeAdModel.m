//
//  FlurryNativeAdModel.m
//  sdk
//
//  Created by Alvarlega on 04/07/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "FlurryNativeAdModel.h"

@interface PNAdModel ()

- (void)invokeDidConfirmImpression;
- (void)invokeDidClick;

@end

@interface FlurryNativeAdModel () <FlurryAdNativeDelegate>

@property (nonatomic, strong)FlurryAdNative *nativeAd;
@property (nonatomic, strong)NSArray        *assets;
@property (nonatomic, strong)NSString       *headline;
@property (nonatomic, strong)NSString       *summary;
@property (nonatomic, strong)NSString       *imageUrl;
@property (nonatomic, strong)NSString       *logoUrl;
@property (nonatomic, strong)NSString       *rating;
@property (nonatomic, strong)NSString       *cta;

@end

@implementation FlurryNativeAdModel

- (void)dealloc
{
    self.nativeAd = nil;
    self.assets = nil;
    self.headline = nil;
    self.summary = nil;
    self.imageUrl = nil;
    self.logoUrl = nil;
    self.rating = nil;
    self.cta = nil;
}

- (instancetype)initWithNativeAd:(FlurryAdNative *)nativeAd
{
    self = [super init];
    if (self) {
        self.nativeAd = nativeAd;
        self.assets = nativeAd.assetList;
        for (FlurryAdNativeAsset* asset in self.assets) {
            if ([asset.name isEqualToString:@"headline"]) {
                self.headline = asset.value;
            }
            if ([asset.name isEqualToString:@"summary"]) {
                self.summary = asset.value;
            }
            
            if ([asset.name isEqualToString:@"secHqBrandingLogo"]) {
                self.logoUrl = asset.value;
            }
            
            if ([asset.name isEqualToString:@"secHqImage"]) {
                self.imageUrl = asset.value;
            }
            
            if ([asset.name isEqualToString:@"appRating"]) {
                self.rating = asset.value;
            }
            
            if ([asset.name isEqualToString:@"callToAction"]) {
                self.cta = asset.value;
            }
        }
    }
    return self;
}

- (NSString*)title
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.headline;
    }
    return result;
}

- (NSString*)description
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.summary;
    }
    return result;
}

- (NSString*)iconURL
{
    NSString *result = nil;
    if (self.nativeAd &&
        self.logoUrl) {
        result = self.logoUrl;
    }
    return result;
}

- (NSString*)bannerURL
{
    NSString *result = nil;
    if (self.nativeAd &&
        self.imageUrl) {
        result = self.imageUrl;
    }
    return result;
}

- (NSString*)callToAction
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.cta;
    }
    return result;
}

- (NSNumber*)starRating
{
    float starRating = 0;
    if (self.nativeAd) {
        starRating = [self.rating floatValue];
    }
    return [NSNumber numberWithFloat:starRating];
}

- (UIView *)contentInfo
{
    return nil;
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    if (self.nativeAd && adView) {
        self.nativeAd.adDelegate = self;
        self.nativeAd.trackingView = adView;
        self.nativeAd.viewControllerForPresentation = viewController;
    }
}

- (void)stopTracking
{
    if (self.nativeAd) {
        [self.nativeAd removeTrackingView];
    }
}

#pragma mark - FlurryAdNativeDelegate delegates

- (void) adNativeDidLogImpression:(FlurryAdNative*) nativeAd
{
    [self invokeDidConfirmImpression];
}

- (void)adNativeDidReceiveClick:(FlurryAdNative *)nativeAd
{
    [self invokeDidClick];
}

@end
