//
//  PNAPIHttpRequestTest.m
//  sdk
//
//  Created by Can Soykarafakili on 04.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNAPIHttpRequest.h"

NSInteger const kStatusCode = 200;

@interface PNAPIHttpRequest ()

@property (nonatomic, strong) NSObject <PNAPIHttpRequestDelegate> *delegate;

- (void)invokeFinishWithData:(NSData*)data statusCode:(NSInteger)statusCode;
- (void)invokeFailWithError:(NSError*)error;

@end

@interface PNAPIHttpRequestTest : XCTestCase

@end

@implementation PNAPIHttpRequestTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_startWithUrlString_WithNilDelegateAndWithValidUrl_shouldPass {
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    [request startWithUrlString:@"validURL" delegate:nil];
}

- (void)test_startWithUrlString_WithValidDelegateAndWithNilUrl_shouldCallbackFail {
    NSObject <PNAPIHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNAPIHttpRequestDelegate));
    NSError *error = mock([NSError class]);
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    request.delegate = delegate;
    [request invokeFailWithError:error];
    [verify(delegate)request:request didFailWithError:error];
}

- (void)test_startWithUrlString_WithValidDelegateAndWithEmptyUrl_shouldCallbackFail {
    NSObject <PNAPIHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNAPIHttpRequestDelegate));
    NSError *error = mock([NSError class]);
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    request.delegate = delegate;
    [request invokeFailWithError:error];
    [verify(delegate)request:request didFailWithError:error];

}

- (void)test_startWithUrlString_WithValidDelegateAndValidUrl_shouldPass {
    NSObject <PNAPIHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNAPIHttpRequestDelegate));
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    [request startWithUrlString:@"validURL" delegate:delegate];
}

- (void)test_invokeFinishWithData_withValidListener_shouldCallback {
    NSObject <PNAPIHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNAPIHttpRequestDelegate));
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    request.delegate = delegate;
    NSData *data = mock([NSData class]);
    [request invokeFinishWithData:data statusCode:kStatusCode];
    [verify(delegate) request:request didFinishWithData:data statusCode:kStatusCode];
}

- (void)test_invokeFinishWithData_withNilListener_shouldPass {
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    NSData *data = mock([NSData class]);
    [request invokeFinishWithData:data statusCode:kStatusCode];
}

- (void)test_invokeFailWithError_withValidListener_shouldCallbackFail {
    NSObject <PNAPIHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNAPIHttpRequestDelegate));
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    request.delegate = delegate;
    NSError *error = mock([NSError class]);
    [request invokeFailWithError:error];
    [verify(delegate)request:request didFailWithError:error];
}

- (void)test_invokeFailWithError_witNilListener_shouldPass {
    PNAPIHttpRequest *request = [[PNAPIHttpRequest alloc] init];
    NSError *error = mock([NSError class]);
    [request invokeFailWithError:error];
}

@end
