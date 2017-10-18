//
//  PNSmallLayoutTest.m
//  sdk
//
//  Created by Can Soykarafakili on 10.08.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "SmallPubnativeLibraryNetworkAdapter.h"
#import "PNSmallLayout.h"

@interface PNSmallLayoutTest : XCTestCase

@end

@implementation PNSmallLayoutTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_startTrackingView_ValidAdapterShouldPass
{
    SmallPubnativeLibraryNetworkAdapter *layoutAdapter = [[SmallPubnativeLibraryNetworkAdapter alloc] init];
    PNSmallLayout *smallLayout = [[PNSmallLayout alloc] init];
    smallLayout.adapter = layoutAdapter;
    [smallLayout startTrackingView];
}

- (void)test_startTrackingView_NilAdapterShouldPass
{
    PNSmallLayout *smallLayout = [[PNSmallLayout alloc] init];
    smallLayout.adapter = nil;
    [smallLayout startTrackingView];
}

- (void)test_stopTrackingView_ValidAdapterShouldPass
{
    SmallPubnativeLibraryNetworkAdapter *layoutAdapter = [[SmallPubnativeLibraryNetworkAdapter alloc] init];
    PNSmallLayout *smallLayout = [[PNSmallLayout alloc] init];
    smallLayout.adapter = layoutAdapter;
    [smallLayout stopTrackingView];
}

- (void)test_stopTrackingView_NilAdapterShouldPass
{
    PNSmallLayout *smallLayout = [[PNSmallLayout alloc] init];
    smallLayout.adapter = nil;
    [smallLayout stopTrackingView];
}

@end
