//
//  FlurryNetworkAdapter.m
//  sdk
//
//  Created by Alvarlega on 04/07/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "FlurryNetworkAdapter.h"
#import "FlurryNativeAdModel.h"
#import "PNError.h"

NSString * const kFlurryNetworkAdapterAPIKey     = @"api_key";
NSString * const kFlurryNetworkAdapterAdSpaceKey = @"ad_space_name";

@interface PNNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PNAdModel*)ad;

@end

@interface FlurryNetworkAdapter () <FlurryAdNativeDelegate>

@property (nonatomic, strong) FlurryAdNative* nativeAd;

@end

@implementation FlurryNetworkAdapter

- (void)dealloc
{
    self.nativeAd = nil;
}

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    NSString *apiKey = data[kFlurryNetworkAdapterAPIKey];
    NSString *adSpace = data[kFlurryNetworkAdapterAdSpaceKey];
    
    if (data == nil || data.count == 0) {
        PNError *dataError = [PNError errorWithDomain:@"FlurryNetworkAdapter - adapter data is null or empty and required"
                                                       code:0
                                                   userInfo:nil];
        [self invokeDidFail:dataError];
    } else if (apiKey == nil || apiKey.length == 0) {
        PNError *apiKeyError = [PNError errorWithDomain:@"FlurryNetworkAdapter - apiKey is null or empty and required"
                                                         code:0
                                                     userInfo:nil];
        [self invokeDidFail:apiKeyError];
    } else if (adSpace == nil || adSpace.length == 0) {
        PNError *placementError = [PNError errorWithDomain:@"FlurryNetworkAdapter - placementId is null or empty and required"
                                                            code:0
                                                        userInfo:nil];
        [self invokeDidFail:placementError];
    } else {
        [self createRequestWithApiKey:apiKey adSpace:adSpace];
    }
}

- (void)createRequestWithApiKey:(NSString*)apiKey adSpace:(NSString*)adSpace
{
    // TODO: Add test mode
    // TODO: Add targeting
    
    self.nativeAd = [[FlurryAdNative alloc] initWithSpace:adSpace];
    self.nativeAd.adDelegate = self;
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    self.nativeAd.viewControllerForPresentation = viewController;
    [self.nativeAd fetchAd];
}

#pragma mark - FlurryAdNativeDelegate delegates

- (void) adNativeDidFetchAd:(FlurryAdNative *)nativeAd
{
    FlurryNativeAdModel *wrapModel = [[FlurryNativeAdModel alloc] initWithNativeAd:nativeAd];
    [self invokeDidLoad:wrapModel];
}

- (void) adNative:(FlurryAdNative*)nativeAd
          adError:(FlurryAdError)adError
 errorDescription:(NSError*) errorDescription
{
    if (adError == FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD) {
        [self invokeDidLoad:nil];
    } else {
        [self invokeDidFail:errorDescription];
    }
}

@end
