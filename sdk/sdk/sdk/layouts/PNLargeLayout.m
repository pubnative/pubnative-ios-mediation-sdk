//
//  PNLargeLayout.m
//  sdk
//
//  Created by Can Soykarafakili on 04.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLargeLayout.h"
#import "PNLargeLayoutAdapter.h"
#import "PNLargeLayoutAdapterFactory.h"

@interface PNLargeLayout () <PNLayoutAdapterViewDelegate>

@property (nonatomic, assign) BOOL shown;

@end

@implementation PNLargeLayout

- (void)show
{
    if (self.adapter) {
        self.adapter.viewDelegate = (NSObject<PNLayoutAdapterViewDelegate>*) self;
        self.adapter.trackDelegate = (NSObject<PNLayoutAdapterTrackDelegate>*) self;
        [self.adapter show];
        [self invokeShow];
    } else {
        NSLog(@"PNLargeLayout.show - Error: This layout is not loaded, did you forgot to load it before?");
    }
}

- (void)hide
{
    if (self.adapter) {
        self.adapter.viewDelegate = nil;
        self.adapter.trackDelegate = nil;
        [self.adapter hide];
        [self invokeHide];
        
    } else {
        NSLog(@"PNLargeLayout.hide - Error: This layout is not loaded, did you forgot to load or show it before?");
    }
}

- (PNLayoutAdapterFactory *)factory
{
    return [PNLargeLayoutAdapterFactory sharedFactory];
}

#pragma mark PNLayoutAdapterViewDelegate

- (void)layoutAdapterDidShow:(PNLayoutAdapter *)adapter
{
    // Do nothing, we already shown the adapter and invokeShow on [self show]
}

- (void)layoutAdapterDidHide:(PNLayoutAdapter *)adapter
{
    [self invokeHide];
}

#pragma mark - Callback Helpers -

- (void)invokeShow
{
    self.shown = YES;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(layoutDidShow:)]) {
        [self.viewDelegate layoutDidShow:self];
    }
}

- (void)invokeHide
{
    self.shown = NO;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(layoutDidHide:)]) {
        [self.viewDelegate layoutDidHide:self];
    }
}

@end
