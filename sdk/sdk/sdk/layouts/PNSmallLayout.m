//
//  PNSmallLayout.m
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNSmallLayout.h"
#import "PNSmallLayoutAdapter.h"
#import "PNSmallLayoutAdapterFactory.h"

@implementation PNSmallLayout

- (PNSmallLayoutViewController*)viewController
{
    PNSmallLayoutViewController *result = nil;
    if (self.adapter) {
        result = ((PNSmallLayoutAdapter*)self.adapter).viewController;
    } else {
        NSLog(@"PNSmallLayout.viewController - Error: Ad not loaded, or failed during load, please reload it again");
    }
    return result;
}

- (void)startTrackingView
{
    if (self.adapter) {
        self.adapter.trackDelegate = (NSObject<PNLayoutAdapterTrackDelegate>*) self;
        [self.adapter startTracking];
    } else {
        NSLog(@"PNSmallLayout.startTrackingView - Error: Ad not loaded, or failed during load, please reload it again");
    }
}

- (void)stopTrackingView
{
    if (self.adapter) {
        [self.adapter stopTracking];
        self.adapter.trackDelegate = nil;
    } else {
         NSLog(@"PNSmallLayout.stopTrackingView - Error: Ad not loaded, or failed during load, please reload it again");
    }
}
- (PNLayoutAdapterFactory *)factory
{
    return [PNSmallLayoutAdapterFactory sharedFactory];
}

@end
