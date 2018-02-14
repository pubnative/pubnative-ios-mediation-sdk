//
//  FacebookNetworkAdapter.m
//  sdk
//
//  Created by Mohit on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "FacebookNetworkAdapter.h"
#import "FacebookNativeAdModel.h"
#import "PNError.h"
#import "PNSettings.h"

NSInteger const kFacebookNetworkAdapter_NoFillErrorCode = 1001;

NSString * const kFacebookNetworkAdapterPlacementIdKey = @"placement_id";

@interface PNNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PNAdModel*)ad;

@end

@interface FacebookNetworkAdapter () <FBNativeAdDelegate>

@property (strong, nonatomic) FBNativeAd * nativeAd;

@end

@implementation FacebookNetworkAdapter


- (void)dealloc
{
    self.nativeAd = nil;
}

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    NSString *placementId = data[kFacebookNetworkAdapterPlacementIdKey];
    
    if (data == nil) {
        PNError *dataError = [PNError errorWithDomain:@"FlurryNetworkAdapter - adapter data is null or empty and required"
                                                 code:0
                                             userInfo:nil];
        [self invokeDidFail:dataError];
    } else if (placementId == nil || placementId.length == 0) {
        PNError *apiKeyError = [PNError errorWithDomain:@"FlurryNetworkAdapter - placementId is null or empty and required"
                                                   code:0
                                               userInfo:nil];
        [self invokeDidFail:apiKeyError];
    } else {
        [self createRequestWithPlacementId:placementId];
    }
}

- (void)createRequestWithPlacementId:(NSString*)placementId
{
    [FBAdSettings setMediationService:@"Pubnative ML"];
    [FBAdSettings setIsChildDirected:[PNSettings sharedInstance].coppa];
    // TODO: Add test mode
    // TODO: Add targeting parameters
    
    self.nativeAd = [[FBNativeAd alloc] initWithPlacementID:placementId];
    self.nativeAd.delegate = self;
    [self.nativeAd loadAd];
}

#pragma mark - FBNativeAdDelegate implementation -

- (void)nativeAdDidLoad:(FBNativeAd*)nativeAd
{
    FacebookNativeAdModel *wrapModel = [[FacebookNativeAdModel alloc] initWithNativeAd:self.nativeAd];
    [self invokeDidLoad:wrapModel];
}

- (void)nativeAd:(FBNativeAd*)nativeAd didFailWithError:(NSError*)error
{
    if(error.code == kFacebookNetworkAdapter_NoFillErrorCode) {
        [self invokeDidLoad:nil];
    } else {
        [self invokeDidFail:error];
    }
    
}

@end
