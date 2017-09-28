//
//  PubnativeLibraryNetworkAdapterTest.m
//  sdk
//
//  Created by Can Soykarafakili on 04.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PubnativeLibraryNetworkAdapter.h"

NSString * const kPubnativeLibraryNetworkAdapterTestParamKey = @"apptoken";
NSString * const kPubnativeLibraryNetworkAdapterTestParamValue = @"e3886645aabbf0d5c06f841a3e6d77fcc8f9de4469d538ab8a96cb507d0f2660";

@interface PubnativeLibraryNetworkAdapter ()

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PNAdModel*)ad;

@end

@interface PubnativeLibraryNetworkAdapterTest : XCTestCase

@end

@implementation PubnativeLibraryNetworkAdapterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_doRequestWithData_withNilData_shouldCallbackFail {
    PubnativeLibraryNetworkAdapter *adapter = [[PubnativeLibraryNetworkAdapter alloc] init];
    [adapter doRequestWithData:nil extras:nil];
    NSError *error = mock([NSError class]);
    [adapter invokeDidFail:error];
}

- (void)test_doRequestWithData_withEmptyData_shouldCallbackFail {
    PubnativeLibraryNetworkAdapter *adapter = [[PubnativeLibraryNetworkAdapter alloc] init];
    NSError *error = mock([NSError class]);
    NSDictionary *dataDictionary = mock([NSDictionary class]);
    [adapter doRequestWithData:dataDictionary extras:nil];
    [adapter invokeDidFail:error];
}


- (void)test_doRequestWithData_withValidData_shouldPass {
    PubnativeLibraryNetworkAdapter *adapter = [[PubnativeLibraryNetworkAdapter alloc] init];
    NSDictionary *dataDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:kPubnativeLibraryNetworkAdapterTestParamValue,kPubnativeLibraryNetworkAdapterTestParamKey, nil];
    [adapter doRequestWithData:dataDictionary extras:nil];
}

@end
