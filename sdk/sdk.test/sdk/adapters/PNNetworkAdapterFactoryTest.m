//
//  PNNetworkAdapterFactoryTest.m
//  sdk
//
//  Created by Can Soykarafakili on 02.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "PNNetworkAdapterFactory.h"

NSString * const kPNNetworkAdapterFactoryTestValidAdapterName = @"PubnativeLibraryNetworkAdapter";
NSString * const kPNNetworkAdapterFactoryTestInvalidAdapterName = @"invalidAdapterName";


@interface PNNetworkAdapterFactoryTest : XCTestCase

@end

@implementation PNNetworkAdapterFactoryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_createApdaterWithAdapterName_withEmptyAdapterName_shouldPass {
    PNNetworkAdapter *adapter = [PNNetworkAdapterFactory createApdaterWithAdapterName:@""];
    assertThat(adapter, nilValue());
}

- (void)test_createApdaterWithAdapterName_withNilAdapterName_shouldPass {
    PNNetworkAdapter *adapter = [PNNetworkAdapterFactory createApdaterWithAdapterName:nil];
    assertThat(adapter, nilValue());
}

- (void)test_createApdaterWithAdapterName_withValidAdapterName_shouldPass {
    PNNetworkAdapter *adapter = [PNNetworkAdapterFactory createApdaterWithAdapterName:kPNNetworkAdapterFactoryTestValidAdapterName];
    assertThat(adapter, notNilValue());
}

- (void)test_createApdaterWithAdapterName_withInvalidAdapterName_shouldPass {
    PNNetworkAdapter *adapter = [PNNetworkAdapterFactory createApdaterWithAdapterName:kPNNetworkAdapterFactoryTestInvalidAdapterName];
    assertThat(adapter, nilValue());
}

@end
