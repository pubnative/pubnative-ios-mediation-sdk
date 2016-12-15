//
//  PubnativeNetworkRequestTest.m
//  mediation
//
//  Created by David Martin on 11/04/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#import "PubnativeNetworkRequest.h"

@interface PubnativeNetworkRequest ()

@property (nonatomic, strong)NSObject <PubnativeNetworkRequestDelegate> *delegate;

- (void)invokeDidStart;
- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end

@interface PubnativeNetworkRequestTest : XCTestCase

@end

@implementation PubnativeNetworkRequestTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_startWithAppToken_withNilAppToken_shouldCallbackFail
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockObjectAndProtocol([NSObject class], @protocol(PubnativeNetworkRequestDelegate));
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    
    [request startWithAppToken:nil
                placementName:@"placement"
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_startWithAppToken_withEmptyAppToken_shouldCallbackFail
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockProtocol(@protocol(PubnativeNetworkRequestDelegate));
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    
    [request startWithAppToken:@""
                 placementName:@"placement"
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_startWithAppToken_withNilPlacement_shouldCallbackFail
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockProtocol(@protocol(PubnativeNetworkRequestDelegate));
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    
    [request startWithAppToken:@"app_token"
                 placementName:nil
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_startWithAppToken_withEmptyPlacement_shouldCallbackFail
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockProtocol(@protocol(PubnativeNetworkRequestDelegate));
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    
    [request startWithAppToken:@"app_token"
                 placementName:@""
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_invokeDidLoad_withValidListener_shouldCallback
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockProtocol(@protocol(PubnativeNetworkRequestDelegate));
    PubnativeAdModel *model = mock([PubnativeAdModel class]);
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    request.delegate = delegate;
    [request invokeDidLoad:model];
    [verify(delegate) pubnativeRequest:request didLoad:model];
}

- (void)test_invokeDidFail_withValidListener_shouldCallback
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockProtocol(@protocol(PubnativeNetworkRequestDelegate));
    NSError *error = mock([NSError class]);
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    request.delegate = delegate;
    [request invokeDidFail:error];
    [verify(delegate) pubnativeRequest:request didFail:error];
}

- (void)test_invokeDidStart_withValidListener_shouldCallback
{
    NSObject<PubnativeNetworkRequestDelegate> *delegate = mockProtocol(@protocol(PubnativeNetworkRequestDelegate));
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];;
    request.delegate = delegate;
    
    [request invokeDidStart];
    [verify(delegate) pubnativeRequestDidStart:request];
}

- (void)test_invokeDidLoad_withNilListener_shouldPass
{
    PubnativeAdModel *model = mock([PubnativeAdModel class]);
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    [request invokeDidLoad:model];
}

- (void)test_invokeDidFail_withNilListener_shouldPass
{
    NSError *error = mock([NSError class]);
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    [request invokeDidFail:error];
}

- (void)test_invokeDidStart_withNilListener_shouldPass
{
    PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init];
    [request invokeDidStart];
}

@end
