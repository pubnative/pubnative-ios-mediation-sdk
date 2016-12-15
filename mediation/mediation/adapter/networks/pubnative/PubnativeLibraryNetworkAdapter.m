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
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        // Server overrides manual set up
        if(extras) {
            [parameters addEntriesFromDictionary:extras];
        }
        if(data){
            [parameters addEntriesFromDictionary:data];
        }
        
        [self createRequestWithParameters:parameters];
        
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeLibraryNetworkAdapter.doRequest - data not availabel"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)createRequestWithParameters:(NSDictionary*)parameters
{
    __weak typeof(self) weakSelf = self;
    self.request = [PNAdRequest request:PNAdRequest_Native
                         withParameters:nil
                                 extras:parameters
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
