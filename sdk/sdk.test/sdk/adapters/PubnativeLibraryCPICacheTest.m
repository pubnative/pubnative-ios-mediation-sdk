//
//  PubnativeLibraryCPICacheTest.m
//  sdk
//
//  Created by Can Soykarafakili on 03.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PubnativeLibraryCPICache.h"
#import "PNConfigModel.h"

@interface PubnativeLibraryCPICacheTest : XCTestCase

@end

@implementation PubnativeLibraryCPICacheTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_initWithAppToken_withEmptyAppTokenAndValidModel_shouldCallback {
    PNConfigModel *model = mock([PNConfigModel class]);
    [PubnativeLibraryCPICache initWithAppToken:@"" config:model];
}

- (void)test_initWithAppToken_withNilAppTokenAndValidModel_shouldCallback {
    PNConfigModel *model = mock([PNConfigModel class]);
    [PubnativeLibraryCPICache initWithAppToken:nil config:model];
}

- (void)test_initWithAppToken_withValidAppTokenAndValidModel_shouldCallback {
    PNConfigModel *model = mock([PNConfigModel class]);
    [PubnativeLibraryCPICache initWithAppToken:@"appToken" config:model];
}

@end
