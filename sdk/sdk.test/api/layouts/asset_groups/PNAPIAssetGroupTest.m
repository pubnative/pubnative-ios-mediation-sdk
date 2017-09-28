//
//  PNAPIAssetGroupTest.m
//  sdk
//
//  Created by Can Soykarafakili on 13.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "PNAPIAssetGroup.h"
#import "PNAPIAssetGroup1.h"

@interface PNAPIAssetGroupTest : XCTestCase

@end

@implementation PNAPIAssetGroupTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_invokeLoadFinish_withValidListener_shouldCallback
{
    NSObject<PNAPIAssetGroupLoadDelegate> *delegate = mockProtocol(@protocol(PNAPIAssetGroupLoadDelegate));
    PNAPIAssetGroup1 *assetGroup = [[PNAPIAssetGroup1 alloc] init];
    assetGroup.loadDelegate = delegate;
    [assetGroup invokeLoadFinish];
    [verify(delegate) assetGroupLoadDidFinish:assetGroup];
}

- (void)test_invokeLoadFail_withValidListener_shouldCallback
{
    NSObject<PNAPIAssetGroupLoadDelegate> *delegate = mockProtocol(@protocol(PNAPIAssetGroupLoadDelegate));
    NSError *error = mock([NSError class]);
    PNAPIAssetGroup1 *assetGroup = [[PNAPIAssetGroup1 alloc] init];
    assetGroup.loadDelegate = delegate;
    [assetGroup invokeLoadFail:error];
    [verify(delegate) assetGroup:assetGroup loadDidFail:error];
}


@end
