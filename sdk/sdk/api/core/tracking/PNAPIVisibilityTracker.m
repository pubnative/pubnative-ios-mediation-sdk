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

#import "PNAPIVisibilityTracker.h"
#import "PNAPIVisibilityTrackerItem.h"

NSTimeInterval const kPNAPIVisibilityTrackerPeriod = 0.1f; // 100ms

@interface PNAPIVisibilityTracker ()

@property (nonatomic, assign)BOOL                                       isVisibilityScheduled;
@property (nonatomic, strong)NSMutableArray<PNAPIVisibilityTrackerItem*>   *trackedItems;
@property (nonatomic, strong)NSMutableArray<UIView*>                    *visibleViews;
@property (nonatomic, strong)NSMutableArray<UIView*>                    *invisibleViews;
@property (nonatomic, strong)NSMutableArray<PNAPIVisibilityTrackerItem*>   *removedItems;
@property (nonatomic, assign)BOOL                                       isValid;

@end

@implementation PNAPIVisibilityTracker

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.isValid = NO;
    self.isVisibilityScheduled = NO;
    
    self.delegate = nil;
    [self.trackedItems removeAllObjects];
    self.trackedItems = nil;
    [self.visibleViews removeAllObjects];
    self.visibleViews = nil;
    [self.invisibleViews removeAllObjects];
    self.invisibleViews = nil;
    [self.removedItems removeAllObjects];
    self.removedItems = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isValid = YES;
        self.trackedItems = [NSMutableArray array];
        self.visibleViews = [NSMutableArray array];
        self.invisibleViews = [NSMutableArray array];
        self.removedItems = [NSMutableArray array];
    }
    return self;
}

#pragma mark
#pragma mark PNAPIVisibilityTracker
#pragma mark

#pragma mark public

- (void)addView:(UIView*)view minVisibility:(CGFloat)minVisibility
{
    if(view == nil) {
        NSLog(@"PNAPIVisibilityTracker - view is nill and required, dropping this call");
    } else if ([self isTrackingView:view]){
        NSLog(@"PNAPIVisibilityTracker - view is already being tracked, dropping this call");
    } else {
        PNAPIVisibilityTrackerItem *item = [[PNAPIVisibilityTrackerItem alloc] init];
        item.view = view;
        item.minVisibility = minVisibility;
        [self.trackedItems addObject:item];
        [self scheduleVisibilityCheck];
    }
}

- (void)removeView:(UIView*)view
{

}

- (void)clear
{
    self.isValid = NO;
    [self.trackedItems removeAllObjects];
    self.isVisibilityScheduled = NO;
}

#pragma mark tracking views

- (BOOL)isTrackingView:(UIView*)view
{
    return [self indexOfView:view] >= 0;
}

- (NSInteger)indexOfView:(UIView*)view
{
    NSInteger result = -1;
    
    for (int i = 0; i < self.trackedItems.count; i++) {
        PNAPIVisibilityTrackerItem *item = self.trackedItems[i];
        if (item != nil && view == item.view) {
            result = i;
            break;
        }
    }
    
    return result;
}

#pragma mark visibility check

- (void)scheduleVisibilityCheck
{
    if(self.isValid && !self.isVisibilityScheduled) {
        
        self.isVisibilityScheduled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPNAPIVisibilityTrackerPeriod * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self checkVisibility];
        });
    }
}

- (void)checkVisibility
{
    for (PNAPIVisibilityTrackerItem *item in self.trackedItems) {
        
        // For safety we need to ensure that the view being tracked wasn't removed, in which case we stop tracking It
        if (item != nil) {
            if (item.view == nil || item.view.superview == nil) {
                [self.removedItems addObject:item];
            } else if (![self.removedItems containsObject:item]) {
                if([self isVisibleView:item.view]
                   && [self view:item.view visibleWithMinPercent:item.minVisibility]) {
                    [self.visibleViews addObject:item.view];
                } else {
                    [self.invisibleViews addObject:item.view];
                }
            }
        }
    }
    
    // We clear up all removed views
    for (PNAPIVisibilityTrackerItem *item in self.removedItems) {
        
        if(item != nil) {
            [self.trackedItems removeObject:item];
        }
    }
    [self.removedItems removeAllObjects];
    
    [self invokeCheckWithVisible:self.visibleViews invisible:self.invisibleViews];
    [self.visibleViews removeAllObjects];
    [self.invisibleViews removeAllObjects];
    
    self.isVisibilityScheduled = NO;
    [self scheduleVisibilityCheck];
}

#pragma mark visibility helpers

- (BOOL)isVisibleView:(UIView*)view
{
    return (!view.hidden
            && ![self hasHiddenAncestorForView:view]
            && [self inersectsParentViewOfView:view]);
}

- (BOOL)hasHiddenAncestorForView:(UIView*)view
{
    UIView *ancestor = view.superview;
    while (ancestor) {
        if (ancestor.hidden) return YES;
        ancestor = ancestor.superview;
    }
    return NO;
}

- (BOOL)inersectsParentViewOfView:(UIView*)view
{
    UIWindow *parentWindow = [self parentWindowForView:view];
    
    if (parentWindow == nil) {
        return NO;
    }
    
    CGRect viewFrameInWindowCoordinates = [view.superview convertRect:view.frame toView:parentWindow];
    return CGRectIntersectsRect(viewFrameInWindowCoordinates, parentWindow.frame);
}

- (BOOL)view:(UIView*)view visibleWithMinPercent:(CGFloat)percentVisible
{
    UIWindow *parentWindow = [self parentWindowForView:view];
    
    if (parentWindow == nil) {
        return NO;
    }
    
    // We need to call convertRect:toView: on this view's superview rather than on this view itself.
    CGRect viewFrameInWindowCoordinates = [view.superview convertRect:view.frame toView:parentWindow];
    CGRect intersection = CGRectIntersection(viewFrameInWindowCoordinates, parentWindow.frame);
    
    CGFloat intersectionArea = CGRectGetWidth(intersection) * CGRectGetHeight(intersection);
    CGFloat originalArea = CGRectGetWidth(view.bounds) * CGRectGetHeight(view.bounds);
    
    return intersectionArea >= (originalArea * percentVisible);
}

- (UIWindow*)parentWindowForView:(UIView*)view
{
    UIView *ancestor = view.superview;
    while (ancestor) {
        if ([ancestor isKindOfClass:[UIWindow class]]) {
            return (UIWindow *)ancestor;
        }
        ancestor = ancestor.superview;
    }
    return nil;
}

#pragma mark callback helpers

- (void)invokeCheckWithVisible:(NSArray<UIView*>*)visibleViews invisible:(NSArray<UIView*>*)invisibleViews
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(visibilityCheckWithVisible:invisible:)]) {
        [self.delegate visibilityCheckWithVisible:visibleViews invisible:invisibleViews];
    }
}

@end
