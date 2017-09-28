//
//  PNLayoutAdapterFactoryTest.m
//  sdk
//
//  Created by Can Soykarafakili on 12.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNLayoutAdapterFactory.h"
#import "PNSmallLayoutAdapterFactory.h"
#import "PNMediumLayoutAdapterFactory.h"
#import "PNLargeLayoutAdapterFactory.h"

@interface PNLayoutAdapterFactoryTest : XCTestCase

@end

@implementation PNLayoutAdapterFactoryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_smallLayoutGetFactory_returnsSmallFactory \
{
    Class factoryClass = [PNSmallLayoutAdapterFactory class];
    PNLayoutAdapterFactory *factory = [PNSmallLayoutAdapterFactory sharedFactory];
    XCTAssertTrue([factory isKindOfClass:factoryClass]);
}

- (void)test_mediumLayoutGetFactory_returnsMediumFactory
{
    Class factoryClass = [PNMediumLayoutAdapterFactory class];
    PNLayoutAdapterFactory *factory = [PNMediumLayoutAdapterFactory sharedFactory];
    XCTAssertTrue([factory isKindOfClass:factoryClass]);
}

- (void)test_largeLayoutGetFactory_returnsLargeFactory
{
    Class factoryClass = [PNLargeLayoutAdapterFactory class];
    PNLayoutAdapterFactory *factory = [PNLargeLayoutAdapterFactory sharedFactory];
    XCTAssertTrue([factory isKindOfClass:factoryClass]);
}

- (void)test_adapterWithName_withValidName_shouldPass
{
    PNLayoutAdapterFactory *adapterFactory = [[PNLayoutAdapterFactory alloc] init];
    [adapterFactory adapterWithName:@"validAdadpterName"];
}

- (void)test_adapterWithName_withNilName_shouldPass
{
    PNLayoutAdapterFactory *adapterFactory = [[PNLayoutAdapterFactory alloc] init];
    [adapterFactory adapterWithName:nil];
}

- (void)test_adapterWithName_withEmptyName_shouldPass
{
    PNLayoutAdapterFactory *adapterFactory = [[PNLayoutAdapterFactory alloc] init];
    [adapterFactory adapterWithName:@""];
}

@end
