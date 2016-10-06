//
//  PubnativeNetworkAdapter.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapter.h"

@interface PubnativeNetworkAdapter ()

@property (nonatomic, strong) NSObject<PubnativeNetworkAdapterDelegate> *delegate;

@end

@implementation PubnativeNetworkAdapter

#pragma mark - Request -
- (void)startWithData:(NSDictionary *)data
              timeout:(NSTimeInterval)timeout
               extras:(NSDictionary<NSString *,NSString *> *)extras
             delegate:(NSObject<PubnativeNetworkAdapterDelegate> *)delegate
{
    if (delegate) {
        
        if (self.targeting) {
            NSDictionary *dict = [self.targeting toDictionary];
            for (NSString* key in dict) {
                [extras setValue:[dict objectForKey:key] forKey:key];
            }
        }
        
        self.delegate = delegate;
        [self invokeDidStart];
        if (timeout > 0) {
            //timeout is in milliseconds
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * timeout * 0.001);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self requestTimeout];
            });
        }
        [self doRequestWithData:data
                         extras:extras];
        
    } else {
        NSLog(@"PubnativeNetworkAdapter.startWithDelegate: - Error: network adapter delegate not specified");
    }
}

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    NSLog(@"PubnativeNetworkAdapter.doRequest - Error: override me");
}

#pragma mark - Request Timeout -
- (void)requestTimeout
{
    NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ - Error: request timeout", NSStringFromClass([self class])]
                                         code:0
                                     userInfo:nil];
    
    [self invokeDidFail:error];
}

#pragma mark - Ads Invoke -
- (void)invokeDidStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterRequestDidStart:)]) {
        [self.delegate adapterRequestDidStart:self];
    }
}

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapter:requestDidLoad:)]) {
        [self.delegate adapter:self requestDidLoad:ad];
    }
    self.delegate = nil;
}

- (void)invokeDidFail:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapter:requestDidFail:)]) {
        [self.delegate adapter:self requestDidFail:error];
    }
    self.delegate = nil;
}

@end
