//
//  PNMediumLayoutTest.m
//  sdk
//
//  Created by Can Soykarafakili on 10.08.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "MediumPubnativeLibraryNetworkAdapter.h"
#import "PNMediumLayout.h"

@interface PNMediumLayoutTest : XCTestCase

@end

@implementation PNMediumLayoutTest

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
    MediumPubnativeLibraryNetworkAdapter *layoutAdapter = [[MediumPubnativeLibraryNetworkAdapter alloc] init];
    PNMediumLayout *mediumLayout = [[PNMediumLayout alloc] init];
    mediumLayout.adapter = layoutAdapter;
    [mediumLayout startTrackingView];
}

- (void)test_startTrackingView_NilAdapterShouldPass
{
    PNMediumLayout *mediumLayout = [[PNMediumLayout alloc] init];
    mediumLayout.adapter = nil;
    [mediumLayout startTrackingView];
}

- (void)test_stopTrackingView_ValidAdapterShouldPass
{
    MediumPubnativeLibraryNetworkAdapter *layoutAdapter = [[MediumPubnativeLibraryNetworkAdapter alloc] init];
    PNMediumLayout *mediumLayout = [[PNMediumLayout alloc] init];
    mediumLayout.adapter = layoutAdapter;
    [mediumLayout stopTrackingView];
}

- (void)test_stopTrackingView_NilAdapterShouldPass
{
    PNMediumLayout *mediumLayout = [[PNMediumLayout alloc] init];
    mediumLayout.adapter = nil;
    [mediumLayout stopTrackingView];
}

@end
