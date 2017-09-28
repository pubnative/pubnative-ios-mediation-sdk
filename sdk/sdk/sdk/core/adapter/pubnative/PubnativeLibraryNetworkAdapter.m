//
//  PubnativeLibraryNetworkAdapter.m
//  sdk
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeLibraryNetworkAdapter.h"
#import "PubnativeLibraryAdModel.h"
#import "PubnativeLibraryCPICache.h"
#import "PNAPIRequest.h"
#import "PNAPIRequestParameter.h"
#import "PNSettings.h"
#import "PNError.h"

NSString * const kPubnativeLibraryNetworkAdapterAppTokenKey = @"apptoken";

@interface PNNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PNAdModel*)ad;

@end

@interface PubnativeLibraryNetworkAdapter () <PNAPIRequestDelegate>

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) PNAPIRequest *request;

@end

@implementation PubnativeLibraryNetworkAdapter

- (void)dealloc
{
    self.request = nil;
    self.data = nil;
}

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    if (data == nil || data.count == 0) {
        
        PNError *dataError = [PNError errorWithDomain:@"FlurryNetworkAdapter - adapter data is null or empty and required"
                                                       code:0
                                                   userInfo:nil];
        [self invokeDidFail:dataError];
        
    } else {
    
        self.data = data;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        // Server overrides manual set up, EXTRAS first, then DATA
        if(extras) {
            [parameters addEntriesFromDictionary:extras];
        }
        [parameters addEntriesFromDictionary:self.data];
        
        [self createRequestWithParameters:parameters];
    }
}

- (void)createRequestWithParameters:(NSDictionary*)parameters
{
    self.request = [[PNAPIRequest alloc] init];
    [self.request setCoppaMode:[PNSettings sharedInstance].coppa];
    [self.request setTestMode:[PNSettings sharedInstance].test];
    for (NSString *key in parameters) {
        [self.request addParameterWithKey:key value:parameters[key]];
    }
    [self.request startWithDelegate:self];
}

#pragma mark - CALLBACKS -
#pragma mark PNAPIRequestDelegate

- (void)requestDidStart:(PNAPIRequest *)request
{
    // Do nothing
}

- (void)request:(PNAPIRequest *)request didFail:(NSError *)error
{
    [self invokeDidFail:error];
}

- (void)request:(PNAPIRequest *)request didLoad:(NSArray<PNAPIAdModel *> *)ads
{
    PNAPIAdModel *ad = nil;
    NSMutableDictionary *extras = [NSMutableDictionary dictionary];
    
    if(ads != nil && ads.count > 0) {
        ad = ads[0];
    }
    
    if(self.networkConfig.isCPACacheEnabled && (ad == nil || [ad isRevenueModelCPA])) {
        
        PNAPIAdModel *cachedAd = [PubnativeLibraryCPICache get];
        if(cachedAd != nil) {
            // DO REQUEST
            NSString *zoneId = self.data[PNAPIRequestParameter.zoneId];
            if(zoneId != nil && zoneId.length > 0) {
                extras[PNAPIRequestParameter.zoneId] = zoneId;
            }
        }
        ad = cachedAd;
    }
    
    if(ad == nil) {
        // NO FILL ERROR
        [self invokeDidLoad:nil];
    } else {
        [ad setTrackingExtras:extras];
        PubnativeLibraryAdModel *wrapModel = [[PubnativeLibraryAdModel alloc] initWithNativeAd:ad];
        [self invokeDidLoad:wrapModel];
    }
}

@end
