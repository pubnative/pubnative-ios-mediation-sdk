//
//  PubnativeAdModel.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"
#import "PubnativeInsightModel.h"
#import "PubnativeDeliveryManager.h"

@interface PubnativeAdModel ()

@property (nonatomic, assign) BOOL      isImpressionTracked;
@property (nonatomic, assign) BOOL      isClickTracked;

// TODO: Add insight data model

@end

@implementation PubnativeAdModel

- (NSString*)title
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)description
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)iconURL
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)bannerURL
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)callToAction
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSNumber*)starRating
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return @0;
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)stopTracking
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)invokeDidConfirmImpression
{
    if(!self.isImpressionTracked) {
        
        self.isImpressionTracked = YES;
        
        [PubnativeDeliveryManager logImpressionForPlacementName:self.insightModel.placementName];
        [self.insightModel sendImpressionInsight];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pubantiveAdDidConfirmImpression:)]){
            [self.delegate pubantiveAdDidConfirmImpression:self];
        }
    }
}

- (void)invokeDidClick
{
    if(!self.isClickTracked){
        
        self.isClickTracked = YES;
        
        [PubnativeDeliveryManager logImpressionForPlacementName:self.insightModel.placementName];
        [self.insightModel sendClickInsight];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeAdDidClick:)]){
            [self.delegate pubnativeAdDidClick:self];
        }
    }
}

@end
