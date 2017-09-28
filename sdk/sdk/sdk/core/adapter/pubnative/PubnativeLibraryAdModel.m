//
//  PubnativeLibraryAdModel.m
//  sdk
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeLibraryAdModel.h"
#import "PNAdModel+Native.h"

@interface PubnativeLibraryAdModel () <PNAPIAdModelDelegate>

@property (nonatomic, strong)PNAPIAdModel *model;

@end

@implementation PubnativeLibraryAdModel

- (void)dealloc
{
    self.model = nil;
}

- (instancetype)initWithNativeAd:(PNAPIAdModel*)model {
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

- (NSString*)title
{
    NSString *result;
    if (self.model) {
        result = self.model.title;
    }
    return result;
}

- (NSString*)description
{
    NSString *result;
    if (self.model) {
        result = self.model.body;
    }
    return result;
}

- (NSString*)iconURLString
{
    NSString *result;
    if (self.model) {
        result = self.model.iconUrl;
    }
    return result;
}

- (NSString *)bannerURLString
{
    NSString *result;
    if (self.model) {
        result = self.model.bannerUrl;
    }
    return result;
}

- (NSString*)callToAction
{
    NSString *result;
    if (self.model) {
        result = self.model.callToAction;
    }
    return result;
}

- (NSNumber*)starRating
{
    NSNumber *result = @0;
    if (self.model) {
        result = self.model.rating;
    }
    return result;
}

- (UIView*)contentInfo
{
    UIView *result = nil;
    if (self.model) {
        result = self.model.contentInfo;
    }
    return result;
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    if(adView == nil) {
        NSLog(@"PNLibraryAdModel - adView is null or empty and required, dropping this call, tracking won't start");
    } else {
        [self.model setDelegate:self];
        [self.model startTrackingView:adView];
    }
}

- (void)stopTracking
{
    [self.model stopTracking];
    [self.model setDelegate:nil];
}

#pragma mark - CALLBACKS -
#pragma mark PNAPIAdModelDelegate

- (void)adModelDidClick:(PNAPIAdModel *)model
{
    [self invokeDidClick];
}

- (void)adModel:(PNAPIAdModel *)model impressionConfirmedWithView:(UIView *)view
{
    [self invokeDidConfirmImpression];
}

@end
