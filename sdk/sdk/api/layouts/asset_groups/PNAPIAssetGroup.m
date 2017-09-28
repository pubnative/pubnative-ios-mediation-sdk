//
//  PNAPIAssetGroup.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup.h"

CGFloat const kPNCTACornerRadius = 4;

@interface PNAPIAssetGroup ()

@end

@implementation PNAPIAssetGroup

#pragma mark NSObject

- (instancetype)init
{
    self = [super init];
    
    if(self) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        UIView *view = [currentBundle loadNibNamed:NSStringFromClass([self class])
                                             owner:self
                                           options:nil][0];
        super.view = view;
    }
    return self;
}

- (void)dealloc
{
    if(self.model) {
        [self.model stopTracking];
    }
    self.model = nil;
    self.loadDelegate = nil;
}

#pragma mark PNAPIAssetGroup

- (void)invokeImpression
{
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(layoutViewDidConfirmImpression:)]) {
        [self.viewDelegate layoutViewDidConfirmImpression:self];
    }
}

- (void)invokeClick
{
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(layoutViewDidClick:)]) {
        [self.viewDelegate layoutViewDidClick:self];
    }
}

- (void)invokeLoadFail:(NSError*)error
{
    NSObject<PNAPIAssetGroupLoadDelegate> *delegate = self.loadDelegate;
    self.loadDelegate = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(assetGroup:loadDidFail:)]) {
        [delegate assetGroup:self loadDidFail:error];
    }
}


- (void)invokeLoadFinish
{
    NSObject<PNAPIAssetGroupLoadDelegate> *delegate = self.loadDelegate;
    self.loadDelegate = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(assetGroupLoadDidFinish:)]) {
        [delegate assetGroupLoadDidFinish:self];
    }
}

- (void)load
{
    // Do nothing, this method should be overriden
}

#pragma mark - CALLBACKS -
#pragma mark PNAPIAdModelDelegate

- (void)adModel:(PNAPIAdModel*)model impressionConfirmedWithView:(UIView*)view
{
    [self invokeImpression];
}

- (void)adModelDidClick:(PNAPIAdModel*)model
{
    [self invokeClick];
}

@end
