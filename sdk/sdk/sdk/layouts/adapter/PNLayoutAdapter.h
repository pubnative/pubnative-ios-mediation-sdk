//
//  PNLayoutAdapter.h
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLayoutAdapter.h"
#import "PNInsightModel.h"
#import "PNNetworkModel.h"

@protocol PNLayoutAdapterProtocol <NSObject>

@optional
- (void)startTracking;
- (void)stopTracking;
- (void)show;
- (void)hide;

@end

@class PNLayoutAdapter;

@protocol PNLayoutAdapterLoadDelegate <NSObject>

- (void)layoutAdapterDidFinishLoading:(PNLayoutAdapter *)adapter;
- (void)layoutAdapter:(PNLayoutAdapter *)adapter didFailLoading:(NSError *)error;

@end

@protocol PNLayoutAdapterFetchDelegate <NSObject>

- (void)layoutAdapterDidFinishFetching:(PNLayoutAdapter *)adapter;
- (void)layoutAdapter:(PNLayoutAdapter *)adapter didFailFetching:(NSError *)error;

@end

@protocol PNLayoutAdapterTrackDelegate <NSObject>

- (void)layoutAdapterTrackImpression:(PNLayoutAdapter *)adapter;
- (void)layoutAdapterTrackClick:(PNLayoutAdapter *)adapter;

@end

@protocol PNLayoutAdapterViewDelegate <NSObject>

- (void)layoutAdapterDidShow:(PNLayoutAdapter *)adapter;
- (void)layoutAdapterDidHide:(PNLayoutAdapter *)adapter;

@end

@interface PNLayoutAdapter : NSObject <PNLayoutAdapterProtocol>

@property (nonatomic, assign) BOOL isCPICacheEnabled;
@property (nonatomic, strong) PNNetworkModel *networkConfig;
@property (nonatomic, strong) PNInsightModel *insight;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, readonly) NSTimeInterval elapsedTime;
@property (nonatomic, strong) NSObject <PNLayoutAdapterLoadDelegate> *loadDelegate;
@property (nonatomic, strong) NSObject <PNLayoutAdapterFetchDelegate> *fetchDelegate;
@property (nonatomic, strong) NSObject <PNLayoutAdapterTrackDelegate> *trackDelegate;
@property (nonatomic, strong) NSObject <PNLayoutAdapterViewDelegate> *viewDelegate;

- (void)execute:(NSTimeInterval)timeoutInMillis;
- (void)request:(NSDictionary *)networkData;
- (void)fetch;

- (void)invokeDidFinishLoading;
- (void)invokeDidFailLoadingWithError:(NSError *)error;
- (void)invokeDidFinishFetching;
- (void)invokeDidFailFetchingWithError:(NSError *)error;
- (void)invokeImpression;
- (void)invokeClick;
- (void)invokeDidShow;
- (void)invokeDidHide;


@end
