//
//  SmallPubnativeLibraryNetworkAdapter.m
//  sdk
//
//  Created by Can Soykarafakili on 15.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "SmallPubnativeLibraryNetworkAdapter.h"
#import "PNSmallLayoutRequestView.h"
#import "PubnativeLibraryCPICache.h"
#import "PNSmallLibraryAdapterViewController.h"
#import "PNSettings.h"
#import "PNAPILayout.h"
#import "PNError.h"

@interface PNLayoutAdapter (Private)

- (void)request:(NSDictionary *)networkData;
- (void)invokeDidFinishLoading;
- (void)invokeDidFailLoadingWithError:(NSError *)error;
- (void)invokeDidFinishFetching;
- (void)invokeDidFailFetchingWithError:(NSError *)error;
- (void)invokeImpression;
- (void)invokeClick;

@end

@interface SmallPubnativeLibraryNetworkAdapter () <PNAPILayoutFetchDelegate, PNAPILayoutLoadDelegate, PNAPILayoutViewControllerDelegate>

@property (nonatomic, strong) PNAPILayout *layout;
@property (nonatomic, strong) PNAPILayoutViewController *layoutViewController;
@property (nonatomic, strong) PNSmallLayoutContainerViewController *cachedView;

@end

@implementation SmallPubnativeLibraryNetworkAdapter

- (void)dealloc
{
    self.layout = nil;
    self.layoutViewController = nil;
    self.cachedView = nil;
}

- (UIViewController*)viewController
{
    if (self.cachedView == nil) {
        self.cachedView = [[PNSmallLibraryAdapterViewController alloc] initWithViewController:self.layoutViewController];
    }
    return self.cachedView;
}

- (void)request:(NSDictionary *)networkData
{
    if (networkData == nil || networkData.count == 0) {
        [self invokeDidFailLoadingWithError:[PNError errorWithCode:PNError_adapter_illegalArguments]];
    } else {
        self.layoutViewController = nil;
        self.layout = [[PNAPILayout alloc] init];
        for (NSString *key in networkData) {
            NSString *value = [networkData objectForKey:key];
            [self.layout addParameterWithKey:key value:value];
        }
        if ([PNSettings sharedInstance].targeting) {
            NSDictionary *targetingDictionary = [[PNSettings sharedInstance].targeting toDictionary];
            for (NSString *key in targetingDictionary) {
                NSString *value = [targetingDictionary objectForKey:key];
                [self.layout addParameterWithKey:key value:value];
            }
        }
        [self.layout setCoppaMode:[PNSettings sharedInstance].coppa];
        [self.layout setTestMode:[PNSettings sharedInstance].test];
        [self.layout loadWithSize:SMALL loadDelegate:self];
    }
}

- (void)fetch
{
    [self.layout fetchWithDelegate:self];
}

#pragma mark - Protocols -
#pragma mark PNLayoutFeedAdapterProtocol

- (void)startTracking
{
    self.layoutViewController.viewDelegate = self;
    [self.layoutViewController startTracking];
}

- (void)stopTracking
{
    [self.layoutViewController stopTracking];
    self.layoutViewController.viewDelegate = nil;
}

#pragma mark - Delegates -
#pragma mark PNAPILayoutLoadDelegate

- (void)layout:(PNAPILayout *)layout loadDidFinish:(PNAPIAdModel *)model
{
    if (model.isRevenueModelCPA && self.isCPICacheEnabled) {
        PNAPIAdModel *cachedAdModel = [PubnativeLibraryCPICache get];
        if (cachedAdModel) {
            layout.model = model;
        }
    }
    [self invokeDidFinishLoading];
}

- (void)layout:(PNAPILayout *)layout loadDidFail:(NSError *)error
{
    if (self.isCPICacheEnabled) {
        PNAPIAdModel *cachedAdModel = [PubnativeLibraryCPICache get];
        if (cachedAdModel == nil) {
            [self invokeDidFailLoadingWithError:error];
        } else {
            layout.model = cachedAdModel;
            [self invokeDidFinishLoading];
        }
    } else {
        [self invokeDidFailLoadingWithError:error];
    }
}

#pragma mark PNAPILayoutFetchDelegate

- (void)layout:(PNAPILayout *)layout fetchDidFinish:(PNAPILayoutViewController *)viewController
{
    self.layoutViewController = viewController;
    [self invokeDidFinishFetching];
}

- (void)layout:(PNAPILayout *)layout fetchDidFail:(NSError *)error
{
    [self invokeDidFailFetchingWithError:error];
}

#pragma mark PNAPILayoutViewControllerDelegate

- (void)layoutViewDidConfirmImpression:(PNAPILayoutViewController *)view
{
    [self invokeImpression];
}

- (void)layoutViewDidClick:(PNAPILayoutViewController *)view
{
    [self invokeClick];
}

@end
