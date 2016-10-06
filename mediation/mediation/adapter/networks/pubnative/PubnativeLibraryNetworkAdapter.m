//
//  PubnativeLibraryNetworkAdapter.m
//  mediation
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeLibraryNetworkAdapter.h"
#import "PubnativeLibraryAdModel.h"
#import "PNAdRequest.h"
#import "PNNativeAdModel.h"

NSString * const kPubnativeLibraryNetworkAdapterAppTokenKey = @"apptoken";

@interface PubnativeNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end

@interface PubnativeLibraryNetworkAdapter ()

@property (strong, nonatomic) PNAdRequest *request;

@end

@implementation PubnativeLibraryNetworkAdapter

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    if (data) {
        
        NSString *appToken = [data objectForKey:kPubnativeLibraryNetworkAdapterAppTokenKey];
        
        if (appToken && [appToken length] > 0) {
            [self createRequestWithAppToken:appToken extras:extras];
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeLibraryNetworkAdapter.doRequest - Invalid apptoken provided"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
        
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeLibraryNetworkAdapter.doRequest - apptoken not avaliable"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)createRequestWithAppToken:(NSString*)appToken extras:(NSDictionary<NSString*, NSString*>*)extras
{
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    parameters.app_token = appToken;
    // TODO: add extras
    
    __weak typeof(self) weakSelf = self;
    self.request = [PNAdRequest request:PNAdRequest_Native
                         withParameters:parameters
                    
                          andCompletion:^(NSArray *ads, NSError *error) {
                              
                              if(error) {
                                  [weakSelf invokeDidFail:error];
                              }
                              else if ([ads count]>0) {
                                  
                                  PubnativeLibraryAdModel *wrapModel = [[PubnativeLibraryAdModel alloc] initWithNativeAd:[ads firstObject]];
                                  [weakSelf invokeDidLoad:wrapModel];
                              }
                          }];
    
    [self.request startRequest];
}

@end
