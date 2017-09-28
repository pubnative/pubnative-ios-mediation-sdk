//
//  PNLayoutAdapter.m
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayoutAdapter.h"
#import "PNError.h"

@interface PNLayoutAdapter ()

@property (nonatomic, assign) NSTimeInterval requestStartTimeStamp;

@end

@implementation PNLayoutAdapter

- (void)dealloc
{
    self.networkConfig = nil;
    self.insight = nil;
    self.data = nil;
    self.loadDelegate = nil;
    self.fetchDelegate = nil;
    self.trackDelegate = nil;
    self.viewDelegate = nil;
}

#pragma mark - ElapsedTime -

- (NSTimeInterval)elapsedTime
{
    return ([[NSDate date] timeIntervalSince1970] - self.requestStartTimeStamp) * 1000;
}

#pragma mark - Callback helpers -

#pragma mark PNLayoutAdapterLoadDelegate

- (void)invokeDidFinishLoading
{
    NSObject<PNLayoutAdapterLoadDelegate> *delegate = self.loadDelegate;
    self.loadDelegate = nil;
    if (delegate && [delegate respondsToSelector:@selector(layoutAdapterDidFinishLoading:)]) {
        [delegate layoutAdapterDidFinishLoading:self];
    }
    delegate = nil;
}

- (void)invokeDidFailLoadingWithError:(NSError *)error
{
    NSObject<PNLayoutAdapterLoadDelegate> *delegate = self.loadDelegate;
    self.loadDelegate = nil;
    if (delegate && [delegate respondsToSelector:@selector(layoutAdapter:didFailLoading:)]) {
        [delegate layoutAdapter:self didFailLoading:error];
    }
    delegate = nil;
}

#pragma mark PNLayoutAdapterFetchDelegate

- (void)invokeDidFinishFetching
{
    NSObject<PNLayoutAdapterFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    if (delegate && [delegate respondsToSelector:@selector(layoutAdapterDidFinishFetching:)]) {
        [delegate layoutAdapterDidFinishFetching:self];
    }
    delegate = nil;
}

- (void)invokeDidFailFetchingWithError:(NSError *)error
{
    NSObject<PNLayoutAdapterFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    if (delegate && [delegate respondsToSelector:@selector(layoutAdapter:didFailFetching:)]) {
        [delegate layoutAdapter:self didFailFetching:error];
    }
    delegate = nil;
}

#pragma mark PNLayoutAdapterTrackDelegate

- (void)invokeClick
{
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(layoutAdapterTrackClick:)]) {
        [self.trackDelegate layoutAdapterTrackClick:self];
    }
}

- (void)invokeImpression
{
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(layoutAdapterTrackImpression:)]) {
        [self.trackDelegate layoutAdapterTrackImpression:self];
    }
}

#pragma mark PNLayoutAdapterTrackDelegate

- (void)invokeDidShow
{
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(layoutAdapterDidShow:)]) {
        [self.viewDelegate layoutAdapterDidShow:self];
    }
}

- (void)invokeDidHide
{
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(layoutAdapterDidHide:)]) {
        [self.viewDelegate layoutAdapterDidHide:self];
    }
}

#pragma mark - Standard Methods -

- (void)execute:(NSTimeInterval)timeoutInMillis
{
    self.requestStartTimeStamp = [[NSDate date] timeIntervalSince1970];
    [self startTimeout:timeoutInMillis];
    [self request:self.data];
}

#pragma mark - Timeout Helpers -

- (void)startTimeout:(NSTimeInterval)timeoutInMillis
{
    if (timeoutInMillis > 0) {
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * timeoutInMillis);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            [self invokeDidFailLoadingWithError:[PNError errorWithCode:PNError_adapter_timeout]];
        });
    }
}

- (void)request:(NSDictionary *)networkData {}
- (void)fetch {}

@end
