//
//  PubnativeAdModel.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PubnativeInsightModel.h"

@class PubnativeAdModel;

@protocol PubnativeAdModelDelegate <NSObject>

- (void)pubantiveAdDidConfirmImpression:(PubnativeAdModel *)ad;
- (void)pubnativeAdDidClick:(PubnativeAdModel *)ad;

@end

@interface PubnativeAdModel : NSObject

@property (nonatomic, weak) NSObject<PubnativeAdModelDelegate> *delegate;

@property (nonatomic, strong) PubnativeInsightModel *insightModel;

@property (readonly) NSString   *title;
@property (readonly) NSString   *description;
@property (readonly) NSString   *iconURL;
@property (readonly) NSString   *bannerURL;
@property (readonly) NSString   *callToAction;
@property (readonly) NSNumber   *starRating;

@property (nonatomic, weak) UIView  *titleView;
@property (nonatomic, weak) UIView  *descriptionView;
@property (nonatomic, weak) UIView  *iconView;
@property (nonatomic, weak) UIView  *bannerView;
@property (nonatomic, weak) UIView  *callToActionView;
@property (nonatomic, weak) UIView  *starRatingView;

/**
 * Start tracking Ad View
 * @param adView View used to show the ad
 * @param viewController ViewController which contains the adView
 */
- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController;
/**
 * Stop tracking Ad View
 * @param adView View used to show the ad
 */
- (void)stopTracking;

@end
