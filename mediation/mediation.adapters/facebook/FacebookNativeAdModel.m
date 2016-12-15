//
//  FacebookNativeAdModel.m
//  mediation
//
//  Created by Mohit on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "FacebookNativeAdModel.h"

@interface PubnativeAdModel ()

- (void)invokeDidConfirmImpression;
- (void)invokeDidClick;

@end

@interface FacebookNativeAdModel () <FBNativeAdDelegate>

@property(nonatomic,strong)FBNativeAd *nativeAd;

@end

@implementation FacebookNativeAdModel

- (instancetype)initWithNativeAd:(FBNativeAd*)nativeAd
{
    self = [super init];
    if (self) {
        self.nativeAd = nativeAd;
    }
    return self;
}

- (NSString*)title
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.nativeAd.title;
    }
    return result;
}

- (NSString*)description
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.nativeAd.body;
    }
    return result;
}

- (NSString*)iconURL
{
    NSString *result = nil;
    if (self.nativeAd &&
        self.nativeAd.icon &&
        self.nativeAd.icon.url) {
        result = [self.nativeAd.icon.url absoluteString];
    }
    return result;
}

- (NSString*)bannerURL
{
    NSString *result = nil;
    if (self.nativeAd &&
        self.nativeAd.coverImage &&
        self.nativeAd.coverImage.url) {
        result = [self.nativeAd.coverImage.url absoluteString];
    }
    return result;
}

- (NSString*)callToAction
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.nativeAd.callToAction;
    }
    return result;
}

- (NSNumber*)starRating
{
    float starRating = 0;
    if (self.nativeAd) {
        struct FBAdStarRating rating = self.nativeAd.starRating;
        if (rating.scale && rating.value) {
            float ratingScale = rating.scale;
            float ratingValue = rating.value;
            starRating = ((ratingValue / ratingScale) * 5.0);
        }
    }
    return [NSNumber numberWithFloat:starRating];
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    if (self.nativeAd && adView) {
        self.nativeAd.delegate = self;
        [self.nativeAd registerViewForInteraction:adView withViewController:viewController];
    }
}

- (void)stopTracking
{
    if (self.nativeAd) {
        [self.nativeAd unregisterView];
    }
}


#pragma mark - FBNativeAdDelegate implementation

- (void)nativeAdDidClick:(FBNativeAd*)nativeAd
{
    [self invokeDidClick];
}

- (void)nativeAdWillLogImpression:(FBNativeAd*)nativeAd
{
    [self invokeDidConfirmImpression];
    
}

@end
