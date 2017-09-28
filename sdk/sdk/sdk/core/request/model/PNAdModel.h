//
//  PNAdModel.h
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNInsightModel.h"
#import "PNAdModelRenderer.h"

@class PNAdModel;

@protocol PNAdModelDelegate <NSObject>

- (void)pubantiveAdDidConfirmImpression:(PNAdModel *)ad;
- (void)pubnativeAdDidClick:(PNAdModel *)ad;

@end

@interface PNAdModel : NSObject

@property (nonatomic, weak) NSObject<PNAdModelDelegate> *delegate;

@property (readonly) NSString   *title;
@property (readonly) NSString   *description;
@property (readonly) NSString   *callToAction;
@property (readonly) UIImage    *icon;
@property (readonly) UIView     *banner;
@property (readonly) NSNumber   *starRating;
@property (readonly) UIView     *contentInfo;

/**
 * Start tracking Ad View
 * @param view View used to show the ad
 * @param viewController ViewController which contains the adView
 */
- (void)startTrackingView:(UIView*)view
       withViewController:(UIViewController*)viewController;
/**
 * Stop tracking Ad View
 */
- (void)stopTracking;

/**
 * Renders the native ad to the given renderer view
 * @param renderer valid renderer class that points to the view to be rendered
 */
- (void)renderAd:(PNAdModelRenderer*)renderer;

@end
