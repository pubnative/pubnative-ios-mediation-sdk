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

#import "PNAPIImpressionTracker.h"
#import "PNAPIImpressionTrackerItem.h"
#import "PNAPIVisibilityTracker.h"

NSTimeInterval const kPNImpressionCheckPeriod = 0.25f; // Check every 250 ms
CGFloat const kPNVisibilityThreshold = 0.5f; // 50% of the view
CGFloat const kPNVisibilityImpressionTime = 1; // 1 second

// This class is supossed to hold the main behaviour of the impression tracking for a given list of views.
//
// This class delegates the visibility check (colliding with a percent of the screen) to the PNAPIVisibilityTracker class
// once this one tells which views are visible or not, the Impression tracker holds the mechanism to continuously check if a
// view is visible in the screen for a certain amount of time
@interface PNAPIImpressionTracker () <PNAPIVisibilityTrackerDelegate>

@property (nonatomic, weak)NSObject<PNAPIImpressionTrackerDelegate>        *delegate;
@property (nonatomic, strong)NSMutableArray<PNAPIImpressionTrackerItem*>   *visibleViews;
@property (nonatomic, strong)NSMutableArray<UIView*>                    *trackedViews;
@property (nonatomic, strong)PNAPIVisibilityTracker                        *visibilityTracker;
@property (nonatomic, assign)BOOL                                       isVisibiltyCheckScheduled;
@property (nonatomic, assign)BOOL                                       isVisibiltyCheckValid;

@end

@implementation PNAPIImpressionTracker

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.delegate = nil;
    
    [self.trackedViews removeAllObjects];
    self.trackedViews = nil;
    
    [self.visibleViews removeAllObjects];
    self.visibleViews = nil;
    
    self.visibleViews = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.visibleViews = [NSMutableArray array];
        self.trackedViews = [NSMutableArray array];
        self.visibilityTracker = [[PNAPIVisibilityTracker alloc] init];
        self.visibilityTracker.delegate = self;
        self.isVisibiltyCheckScheduled = NO;
        self.isVisibiltyCheckValid = NO;
    }
    return self;
}

#pragma mark
#pragma mark PNAPIImpressionTracker
#pragma mark

#pragma mark public

- (void)setDelegate:(NSObject<PNAPIImpressionTrackerDelegate>*)delegate
{
    _delegate = delegate;
}

- (void)addView:(UIView*)view
{
    if([self.trackedViews containsObject:view]) {
        NSLog(@"PNAPIImpressionTracker - View is already being tracked, dropping this call");
    } else {
        [self.trackedViews addObject:view];
        [self.visibilityTracker addView:view minVisibility:kPNVisibilityThreshold];
    }
}

- (void)removeView:(UIView*)view
{
    [self.visibilityTracker removeView:view];
    [self.trackedViews removeObject:view];
}

- (void)clear
{
    self.isVisibiltyCheckValid = NO;
    self.isVisibiltyCheckScheduled = NO;
    
    [self.visibleViews removeAllObjects];
    self.visibleViews = nil;
    
    [self.visibilityTracker clear];
    self.visibilityTracker = nil;
    
}

#pragma mark private

- (void)scheduleNextRun
{
    if(self.isVisibiltyCheckValid && !self.isVisibiltyCheckScheduled) {
        
        self.isVisibiltyCheckScheduled = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPNImpressionCheckPeriod * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(self.delegate == nil) {
                [self clear];
            } else if(self.visibleViews && self.visibleViews.count > 0){
                [self checkVisibility];
            }
        });
        
    } else {
        self.isVisibiltyCheckValid = YES;
    }
}

- (void)checkVisibility
{
    if(self.visibleViews != nil) {
        
        for (int i = 0; i < self.visibleViews.count; i++) {
            
            if (i < self.visibleViews.count) {
                PNAPIImpressionTrackerItem *item = self.visibleViews[i];
                // It could happen that we've removed the view right when we're tracking, so we simply skip this item
                if([self.trackedViews containsObject:item.view]) {
                    
                    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
                    NSTimeInterval elapsedTime = currentTimestamp - item.timestamp;
                    
                    if(kPNVisibilityImpressionTime <= elapsedTime) {
                        
                        [self removeView:item.view];
                        [self invokeImpressionDetected:item.view];
                    }
                }
            } else {
                // We have emptied the visible views while going through It, so we leave this for
                break;
            }
        }
        
        self.isVisibiltyCheckScheduled = NO;
        if(self.visibleViews.count > 0) {
            [self scheduleNextRun];
        }
    }
}

- (NSInteger)indexOfVisibleView:(UIView*)view
{
    NSInteger result = -1;
    
    for (int index = 0; index<self.visibleViews.count; index++) {
        
        PNAPIImpressionTrackerItem *item = self.visibleViews[index];
        if(item.view == view) {
            result = index;
            break;
        }
    }
    return result;
}


#pragma mark Callback helper

- (void)invokeImpressionDetected:(UIView*)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(impressionDetectedWithView:)]) {
        [self.delegate impressionDetectedWithView:view];
    }
}

#pragma mark
#pragma mark CALLBACKS
#pragma mark

#pragma mark PNAPIVisibilityTrackerDelegate

- (void)visibilityCheckWithVisible:(NSArray<UIView *> *)visibleViews invisible:(NSArray<UIView *> *)invisibleViews
{
    if(self.delegate == nil) {
        
        [self clear];
        
    } else {
        
        for (UIView *visibleView in visibleViews) {
            
            NSInteger index = [self indexOfVisibleView:visibleView];
            PNAPIImpressionTrackerItem *item;
            if(index < 0) {
                
                // First time it's visible, add it
                item = [[PNAPIImpressionTrackerItem alloc] init];
                item.view = visibleView;
                item.timestamp = [[NSDate date] timeIntervalSince1970];
                [self.visibleViews addObject:item];
            }
        }
        
        for (UIView *invisibleView in invisibleViews) {
            
            NSInteger index = [self indexOfVisibleView:invisibleView];
            if(index >= 0) {
                [self.visibleViews removeObjectAtIndex:index];
            }
        }
        
        if (self.visibleViews.count > 0) {
            
            [self scheduleNextRun];
        }
    }
}

@end
