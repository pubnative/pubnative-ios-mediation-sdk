//
//  PNNetworkAdapter.m
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNNetworkAdapter.h"
#import "PNError.h"

@interface PNNetworkAdapter ()

@property (nonatomic, strong) NSObject<PNNetworkAdapterDelegate> *delegate;

@end

@implementation PNNetworkAdapter

#pragma mark - NSObject -

- (void)dealloc
{
    self.networkConfig = nil;
    self.delegate = nil;
}

#pragma mark - Request -
- (void)startWithExtras:(NSDictionary<NSString *,NSString *> *)extras
               delegate:(NSObject<PNNetworkAdapterDelegate> *)delegate
{
    if (delegate) {
        
        self.delegate = delegate;
        [self invokeDidStart];
        if (self.networkConfig.timeoutInSeconds > 0) {
            //timeout is in milliseconds
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * self.networkConfig.timeoutInSeconds);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self requestTimeout];
            });
        }
        [self doRequestWithData:self.networkConfig.params
                         extras:extras];
        
    } else {
        NSLog(@"PNNetworkAdapter.startWithDelegate: - Error: network adapter delegate not specified");
    }
}

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    NSLog(@"PNNetworkAdapter.doRequest - Error: override me");
}

#pragma mark - Request Timeout -
- (void)requestTimeout
{
    PNError *error = [PNError errorWithDomain:[NSString stringWithFormat:@"%@ - Error: request timeout", NSStringFromClass([self class])]
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

- (void)invokeDidLoad:(PNAdModel*)ad
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
