//
//  LargePubnativeLibraryNetworkAdapterTest.m
//  sdk
//
//  Created by Can Soykarafakili on 13.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "LargePubnativeLibraryNetworkAdapter.h"

@interface LargePubnativeLibraryNetworkAdapterTest : XCTestCase

@end

@implementation LargePubnativeLibraryNetworkAdapterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)test_request_withNilData_shouldPass
{
    LargePubnativeLibraryNetworkAdapter *adapter = [[LargePubnativeLibraryNetworkAdapter alloc] init];
    [adapter request:nil];
}

- (void)test_request_withEmptyData_shouldPass
{
    LargePubnativeLibraryNetworkAdapter *adapter = [[LargePubnativeLibraryNetworkAdapter alloc] init];
    NSDictionary *data = [[NSDictionary alloc] init];
    [adapter request:data];
}

- (void)test_request_withValidData_shouldPass
{
    LargePubnativeLibraryNetworkAdapter *adapter = [[LargePubnativeLibraryNetworkAdapter alloc] init];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:@"validObject",@"validKey", nil];
    [adapter request:data];
}

@end
