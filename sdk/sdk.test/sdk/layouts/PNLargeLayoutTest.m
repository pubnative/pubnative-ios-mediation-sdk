//
//  PNLargeLayoutTest.m
//  sdk
//
//  Created by Can Soykarafakili on 10.08.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "LargePubnativeLibraryNetworkAdapter.h"
#import "PNLargeLayout.h"

@interface PNLargeLayout()

- (void)invokeShow;
- (void)invokeHide;

@end

@interface PNLargeLayoutTest : XCTestCase

@end

@implementation PNLargeLayoutTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_hide_ValidAdapterShouldPass
{
    LargePubnativeLibraryNetworkAdapter *layoutAdapter = [[LargePubnativeLibraryNetworkAdapter alloc] init];
    PNLargeLayout *largeLayout = [[PNLargeLayout alloc] init];
    largeLayout.adapter = layoutAdapter;
    [largeLayout hide];
}

- (void)test_hide_NilAdapterShouldPass
{
    PNLargeLayout *largeLayout = [[PNLargeLayout alloc] init];
    largeLayout.adapter = nil;
    [largeLayout hide];
}

- (void)test_show_NilAdapterShouldPass
{
    PNLargeLayout *largeLayout = [[PNLargeLayout alloc] init];
    largeLayout.adapter = nil;
    [largeLayout show];
}

- (void)test_invokeShow_withValidListener_shouldCallback
{
    NSObject<PNLayoutViewDelegate> *delegate = mockProtocol(@protocol(PNLayoutViewDelegate));
    PNLargeLayout *largeLayout = [[PNLargeLayout alloc] init];
    largeLayout.viewDelegate = delegate;
    [largeLayout invokeShow];
    [verify(delegate)layoutDidShow:largeLayout];
}

- (void)test_invokeDidFail_withValidListener_shouldCallback
{
    NSObject<PNLayoutViewDelegate> *delegate = mockProtocol(@protocol(PNLayoutViewDelegate));
    PNLargeLayout *largeLayout = [[PNLargeLayout alloc] init];
    largeLayout.viewDelegate = delegate;
    [largeLayout invokeHide];
    [verify(delegate)layoutDidHide:largeLayout];
}

@end
