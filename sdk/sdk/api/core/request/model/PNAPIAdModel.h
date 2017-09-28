//
//  Copyright © 2016 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PNAPIV3AdModel.h"
#import "PNAPIContentView.h"

@class PNAPIAdModel;

@protocol PNAPIAdModelDelegate <NSObject>

- (void)adModel:(PNAPIAdModel*)model impressionConfirmedWithView:(UIView*)view;
- (void)adModelDidClick:(PNAPIAdModel*)model;

@end

@protocol PNAPIAdModelClickConfiguration <NSObject>

- (void)setClickCaching:(BOOL)enabled;
- (void)setClickLoader:(BOOL)enabled;
- (void)setClickBackgroundRedirection:(BOOL)enabled;

@end

@interface PNAPIAdModel : NSObject<PNAPIAdModelClickConfiguration>

// Helper properties
@property (nonatomic, readonly) NSString    *title;
@property (nonatomic, readonly) NSString    *body;
@property (nonatomic, readonly) NSString    *callToAction;
@property (nonatomic, readonly) NSString    *iconUrl;
@property (nonatomic, readonly) NSString    *bannerUrl;
@property (nonatomic, readonly) NSString    *standardBannerUrl;
@property (nonatomic, readonly) NSString    *htmlUrl;
@property (nonatomic, readonly) NSString    *clickUrl;
@property (nonatomic, readonly) NSString    *vast;
@property (nonatomic, readonly) NSNumber    *rating;
@property (nonatomic, readonly) UIView      *contentInfo;
@property (nonatomic, readonly) NSNumber    *assetGroupID;

// Properties
- (instancetype)initWithData:(PNAPIV3AdModel*)data;

- (PNAPIV3DataModel*)assetDataWithType:(NSString*)type;
- (PNAPIV3DataModel*)metaDataWithType:(NSString*)type;

- (BOOL)isRevenueModelCPA;
- (void)fetch;

// Tracking
- (void)setDelegate:(NSObject<PNAPIAdModelDelegate>*)delegate;
- (void)setTrackingExtras:(NSDictionary*)extras;
- (void)startTrackingView:(UIView*)view;
- (void)startTrackingView:(UIView*)view clickableViews:(NSArray*)clickableViews;
- (void)stopTracking;

@end
