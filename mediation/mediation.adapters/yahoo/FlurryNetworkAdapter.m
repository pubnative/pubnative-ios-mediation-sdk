//
//  FlurryNetworkAdapter.m
//  mediation
//
//  Created by Alvarlega on 04/07/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "FlurryNetworkAdapter.h"
#import "FlurryNativeAdModel.h"
#import "Flurry.h"

@interface PubnativeNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end

@interface FlurryNetworkAdapter () <FlurryAdNativeDelegate>

@property (nonatomic, retain) FlurryAdNative* nativeAd;

@end

@implementation FlurryNetworkAdapter

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    if (data != nil) {
        [Flurry startSession:data[@"api_key"]];
        NSString *placementId = data[@"ad_space_name"];
        if (placementId && placementId.length > 0) {
            self.nativeAd = [[FlurryAdNative alloc] initWithSpace:placementId];
            self.nativeAd.adDelegate = self;
            self.nativeAd.viewControllerForPresentation = (UIViewController*)[[[[UIApplication sharedApplication]delegate] window] rootViewController];
            [self.nativeAd fetchAd];
        }
    }
}

#pragma mark - FlurryAdNativeDelegate delegates

- (void) adNativeDidFetchAd:(FlurryAdNative *)nativeAd
{
    NSLog(@"adNativeDidFetchAd");
    FlurryNativeAdModel *wrapModel = [[FlurryNativeAdModel alloc] initWithNativeAd:nativeAd];
    [self invokeDidLoad:wrapModel];
}

- (void) adNative:(FlurryAdNative*)nativeAd
          adError:(FlurryAdError)adError
 errorDescription:(NSError*) errorDescription
{
    NSLog(@"adNative: %u", adError);
    
    if (adError == FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD) {
        NSLog(@"FlurryNetworkAdapter - Fail to fetch Ad");
        [self invokeDidLoad:nil];
    } else {
        [self invokeDidFail:errorDescription];
    }
}

@end
