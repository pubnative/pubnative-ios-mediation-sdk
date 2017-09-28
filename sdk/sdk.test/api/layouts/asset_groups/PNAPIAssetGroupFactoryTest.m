//
//  PNAPIAssetGroupFactoryTest.m
//  sdk
//
//  Created by Can Soykarafakili on 13.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNAPIAssetGroupFactory.h"

@interface PNAPIAssetGroupFactoryTest : XCTestCase

@end

@implementation PNAPIAssetGroupFactoryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_createWithAssetGroupID_withValidAssetGroupID_shouldPass
{
    NSNumber *assetGroupID = mock([NSNumber class]);
    [PNAPIAssetGroupFactory createWithAssetGroupID:assetGroupID];
}

- (void)test_createWithAssetGroupID_withNilAssetGroupID_shouldPass
{
    [PNAPIAssetGroupFactory createWithAssetGroupID:nil];
}

@end
