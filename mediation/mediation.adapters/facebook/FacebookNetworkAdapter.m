//
//  FacebookNetworkAdapter.m
//  mediation
//
//  Created by Mohit on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "FacebookNetworkAdapter.h"
#import "FacebookNativeAdModel.h"

NSString * const kPlacementIdKey = @"placement_id";

@interface PubnativeNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end

@interface FacebookNetworkAdapter () <FBNativeAdDelegate>

@property (strong, nonatomic) FBNativeAd * nativeAd;

@end

@implementation FacebookNetworkAdapter

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    if (data != nil) {
        NSString *placementId = data[kPlacementIdKey];
        if (placementId && [placementId length] > 0) {
            [self createRequestWithPlacementId:placementId];
        } else {
            NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter.doRequest - Invalid placement id provided"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter.doRequest - Illegal data detected"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)createRequestWithPlacementId:(NSString*)placementId
{
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
    [self invokeDidFail:error];
}

@end
