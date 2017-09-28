//
//  PNRequestTest.m
//  sdk
//
//  Created by David Martin on 11/04/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#import "PNRequest.h"

@interface PNRequest ()

@property (nonatomic, strong)NSObject <PNRequestDelegate> *delegate;

- (void)invokeDidStart;
- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PNAdModel*)ad;

@end

@interface PNRequestTest : XCTestCase

@end

@implementation PNRequestTest

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
    NSObject<PNRequestDelegate> *delegate = mockObjectAndProtocol([NSObject class], @protocol(PNRequestDelegate));
    PNRequest *request = [[PNRequest alloc] init];
    
    [request startWithAppToken:nil
                placementName:@"placement"
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_startWithAppToken_withEmptyAppToken_shouldCallbackFail
{
    NSObject<PNRequestDelegate> *delegate = mockProtocol(@protocol(PNRequestDelegate));
    PNRequest *request = [[PNRequest alloc] init];
    
    [request startWithAppToken:@""
                 placementName:@"placement"
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_startWithAppToken_withNilPlacement_shouldCallbackFail
{
    NSObject<PNRequestDelegate> *delegate = mockProtocol(@protocol(PNRequestDelegate));
    PNRequest *request = [[PNRequest alloc] init];
    
    [request startWithAppToken:@"app_token"
                 placementName:nil
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_startWithAppToken_withEmptyPlacement_shouldCallbackFail
{
    NSObject<PNRequestDelegate> *delegate = mockProtocol(@protocol(PNRequestDelegate));
    PNRequest *request = [[PNRequest alloc] init];
    
    [request startWithAppToken:@"app_token"
                 placementName:@""
                      delegate:delegate];
    
    [verify(delegate) pubnativeRequest:request didFail:instanceOf([NSError class])];
}

- (void)test_invokeDidLoad_withValidListener_shouldCallback
{
    NSObject<PNRequestDelegate> *delegate = mockProtocol(@protocol(PNRequestDelegate));
    PNAdModel *model = mock([PNAdModel class]);
    PNRequest *request = [[PNRequest alloc] init];
    request.delegate = delegate;
    [request invokeDidLoad:model];
    [verify(delegate) pubnativeRequest:request didLoad:model];
}

- (void)test_invokeDidFail_withValidListener_shouldCallback
{
    NSObject<PNRequestDelegate> *delegate = mockProtocol(@protocol(PNRequestDelegate));
    NSError *error = mock([NSError class]);
    PNRequest *request = [[PNRequest alloc] init];
    request.delegate = delegate;
    [request invokeDidFail:error];
    [verify(delegate) pubnativeRequest:request didFail:error];
}

- (void)test_invokeDidStart_withValidListener_shouldCallback
{
    NSObject<PNRequestDelegate> *delegate = mockProtocol(@protocol(PNRequestDelegate));
    PNRequest *request = [[PNRequest alloc] init];;
    request.delegate = delegate;
    
    [request invokeDidStart];
    [verify(delegate) pubnativeRequestDidStart:request];
}

- (void)test_invokeDidLoad_withNilListener_shouldPass
{
    PNAdModel *model = mock([PNAdModel class]);
    PNRequest *request = [[PNRequest alloc] init];
    [request invokeDidLoad:model];
}

- (void)test_invokeDidFail_withNilListener_shouldPass
{
    NSError *error = mock([NSError class]);
    PNRequest *request = [[PNRequest alloc] init];
    [request invokeDidFail:error];
}

- (void)test_invokeDidStart_withNilListener_shouldPass
{
    PNRequest *request = [[PNRequest alloc] init];
    [request invokeDidStart];
}

@end
