//
//  PubnativeLibraryAdModel.m
//  mediation
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeLibraryAdModel.h"
#import "PNTrackingManager.h"

@interface PubnativeAdModel (Private)

- (void)invokeDidConfirmImpression;
- (void)invokeDidClick;

@end

@interface PubnativeLibraryAdModel ()

@property (nonatomic, strong)PNNativeAdModel *model;
@property (nonatomic, weak) UIView *trackingView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation PubnativeLibraryAdModel

- (instancetype)initWithNativeAd:(PNNativeAdModel*)model {
    self = [super init];
    if (self) {
        self.model = model;
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped)];
    }
    return self;
}

- (NSString*)title
{
    NSString *result;
    if (self.model) {
        result = self.model.title;
    }
    return result;
}

- (NSString*)description
{
    NSString *result;
    if (self.model) {
        result = self.model.Description;
    }
    return result;
}

- (NSString*)iconURL
{
    NSString *result;
    if (self.model) {
        result = self.model.icon_url;
    }
    return result;
}

- (NSString*)bannerURL
{
    NSString *result;
    if (self.model) {
        result = self.model.banner_url;
    }
    return result;
}

- (NSString*)callToAction
{
    NSString *result;
    if (self.model) {
        result = self.model.cta_text;
    }
    return result;
}

- (NSNumber*)starRating
{
    float starRating = 0;
    if (self.model &&
        self.model.app_details &&
        self.model.app_details.store_rating) {
        starRating = [self.model.app_details.store_rating floatValue];
    }
    return [NSNumber numberWithFloat:starRating];
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    if (self.model && adView) {
        
        // Tracking click
        self.trackingView = adView;
        [self.trackingView addGestureRecognizer:self.tapRecognizer];
        
        [PNTrackingManager trackImpressionWithAd:self.model
                                      completion:^(id result, NSError *error) {
           
            if(error){
                NSLog(@"PubnativeLibraryAdModel - Error confirming impression: %@", error);
            } else {
                [self invokeDidConfirmImpression];
            }
        }];
    
    } else {
        NSLog(@"PubnativeLibraryAdModel - Error: model or adView was null or empty, dropping this call, tracking won't start");
    }
}

- (void)stopTracking
{
    [self.trackingView removeGestureRecognizer:self.tapRecognizer];
}

/**
 *  Invoke when ad View associated with the PNNativeAdModel tapped
 */
- (void)adViewTapped {
    
    [self invokeDidClick];
    if (self.model && self.model.click_url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

@end
