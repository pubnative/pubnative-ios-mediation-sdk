//
//  PNLayoutTest.m
//  sdk
//
//  Created by Can Soykarafakili on 12.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNLayout.h"
#import "PNConfigModel.h"
#import "PNError.h"

@interface PNLayout()

- (void)startRequestWithConfig:(PNConfigModel*)config;
- (void)invokeDidFinish;
- (void)invokeDidFailWithError:(NSError *)error;

@end

@interface PNLayoutTest : XCTestCase

@end

@implementation PNLayoutTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_loadWithAppToken_withNilListener_shouldPass
{
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = nil;
    [layout loadWithAppToken:@"validAppToken" placement:@"validPlacement"];
}

- (void)test_loadWithAppToken_withValidAppToken_andWithValidPlacement_shouldPass
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout loadWithAppToken:@"validAppToken" placement:@"validPlacement"];
}

- (void)test_loadWithAppToken_withEmptyAppToken_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout loadWithAppToken:@"" placement:@"validPlacement"];
    [layout invokeDidFailWithError:error];
}

- (void)test_loadWithAppToken_withNilAppToken_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout loadWithAppToken:nil placement:@"validPlacement"];
    [layout invokeDidFailWithError:error];
}

- (void)test_loadWithAppToken_withEmptyPlacement_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout loadWithAppToken:@"validAppToken" placement:@""];
    [layout invokeDidFailWithError:error];
}

- (void)test_loadWithAppToken_withNilPlacement_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout loadWithAppToken:@"validAppToken" placement:nil];
    [layout invokeDidFailWithError:error];
}

- (void)test_startRequest_withValidConfig_shouldPass
{
    PNLayout *layout = [[PNLayout alloc] init];
    PNConfigModel *model = mock([PNConfigModel class]);
    [layout startRequestWithConfig:model];
}

- (void)test_startRequest_withNilConfig_shouldCallbackFail
{
    PNLayout *layout = [[PNLayout alloc] init];
    PNError *error = mock([PNError class]);
    [layout startRequestWithConfig:nil];
    [layout invokeDidFailWithError:error];
}

- (void)test_invokeDidFinish_withValidListener_shouldCallback
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout invokeDidFinish];
    [verify(delegate)layoutDidFinishLoading:layout];
}

- (void)test_invokeDidFail_withValidListener_shouldCallback
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    NSError *error = mock([NSError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    layout.loadDelegate = delegate;
    [layout invokeDidFailWithError:error];
    [verify(delegate)layout:layout didFailLoading:error];
}


@end
