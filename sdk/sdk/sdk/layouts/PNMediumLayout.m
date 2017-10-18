//
//  PNMediumLayout.m
//  sdk
//
//  Created by Can Soykarafakili on 23.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNMediumLayout.h"
#import "PNMediumLayoutAdapter.h"
#import "PNMediumLayoutAdapterFactory.h"

@implementation PNMediumLayout

- (void)loadWithAppToken:(NSString *)appToken
               placement:(NSString *)placement
                delegate:(NSObject<PNLayoutLoadDelegate> *)delegate
{
    [self stopTrackingView];
    if (self.viewController) {
        [self.viewController.view removeFromSuperview];
        [self.viewController willMoveToParentViewController:nil];
        [self.viewController removeFromParentViewController];
    }
    [super loadWithAppToken:appToken placement:placement delegate:delegate];
}

- (PNMediumLayoutViewController*)viewController
{
    PNMediumLayoutViewController *result = nil;
    if (self.adapter) {
        result = ((PNMediumLayoutAdapter*)self.adapter).viewController;
    } else {
        NSLog(@"PNMediumLayout.viewController - Error: Ad not loaded, or failed during load, please reload it again");
    }
    return result;
}

- (void)startTrackingView
{
    if (self.adapter) {
        self.adapter.trackDelegate = (NSObject<PNLayoutAdapterTrackDelegate>*) self;
        [self.adapter startTracking];
    } else {
        NSLog(@"PNMediumLayout.startTrackingView - Error: Ad not loaded, or failed during load, please reload it again");
    }
}

- (void)stopTrackingView
{
    if (self.adapter) {
        [self.adapter stopTracking];
        self.adapter.trackDelegate = nil;
    } else {
        NSLog(@"PNMediumLayout.stopTrackingView - Error: Ad not loaded, or failed during load, please reload it again");
    }
}
- (PNLayoutAdapterFactory *)factory
{
    return [PNMediumLayoutAdapterFactory sharedFactory];
}

@end
