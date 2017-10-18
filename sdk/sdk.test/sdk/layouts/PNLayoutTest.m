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

@property (nonatomic, weak) NSObject<PNLayoutLoadDelegate> *loadDelegate;

- (void)startRequestWithConfig:(PNConfigModel*)config;
- (void)invokeDidFinish;
- (void)invokeDidFailWithError:(NSError *)error;
- (void)invokeClick;
- (void)invokeImpression;
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
    [layout loadWithAppToken:@"validAppToken" placement:@"validPlacement" delegate:nil];
}

- (void)test_loadWithAppToken_withValidAppToken_andWithValidPlacement_shouldPass
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNLayout *layout = [[PNLayout alloc] init];
    [layout loadWithAppToken:@"validAppToken" placement:@"validPlacement" delegate:delegate];
}

- (void)test_loadWithAppToken_withEmptyAppToken_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    [layout loadWithAppToken:@"" placement:@"validPlacement" delegate:delegate];
    [layout invokeDidFailWithError:error];
}

- (void)test_loadWithAppToken_withNilAppToken_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    [layout loadWithAppToken:nil placement:@"validPlacement" delegate:delegate];
    [layout invokeDidFailWithError:error];
}

- (void)test_loadWithAppToken_withEmptyPlacement_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    [layout loadWithAppToken:@"validAppToken" placement:@"" delegate:delegate];
    [layout invokeDidFailWithError:error];
}

- (void)test_loadWithAppToken_withNilPlacement_shouldCallbackFail
{
    NSObject<PNLayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutLoadDelegate));
    PNError *error = mock([PNError class]);
    PNLayout *layout = [[PNLayout alloc] init];
    [layout loadWithAppToken:@"validAppToken" placement:nil delegate:delegate];
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

- (void)test_invokeClick_withValidListener_shouldCallback
{
    NSObject<PNLayoutTrackDelegate> *delegate = mockProtocol(@protocol(PNLayoutTrackDelegate));
    PNLayout *layout = [[PNLayout alloc] init];
    layout.trackDelegate = delegate;
    [layout invokeClick];
    [verify(delegate)layoutTrackClick:layout];
}

- (void)test_invokeImpression_withValidListener_shouldCallback
{
    NSObject<PNLayoutTrackDelegate> *delegate = mockProtocol(@protocol(PNLayoutTrackDelegate));
    PNLayout *layout = [[PNLayout alloc] init];
    layout.trackDelegate = delegate;
    [layout invokeImpression];
    [verify(delegate)layoutTrackImpression:layout];
}


@end
