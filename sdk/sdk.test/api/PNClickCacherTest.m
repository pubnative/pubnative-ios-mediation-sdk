//
//  PNAPIClickCacherTest.m
//  sdk
//
//  Created by Can Soykarafakili on 05.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNAPIClickCacher.h"

@interface PNAPIClickCacher ()

@property (nonatomic, strong) NSObject <PNAPIClickCacherDelegate> *delegate;

@end

@interface PNAPIClickCacherTest : XCTestCase

@end

@implementation PNAPIClickCacherTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_cacheWithURLString_withValidUrlAndValidDelegate_shouldPass {
    NSObject<PNAPIClickCacherDelegate> *delegate = mockProtocol(@protocol(PNAPIClickCacherDelegate));
    PNAPIClickCacher *clickCacher = [[PNAPIClickCacher alloc] init];
    clickCacher.delegate = delegate;
    [clickCacher cacheWithURLString:@"validUrl" delegate:delegate];
}

- (void)test_cacheWithURLString_withValidUrlAndNilDelegate_shouldPass {
    PNAPIClickCacher *clickCacher = [[PNAPIClickCacher alloc] init];
    [clickCacher cacheWithURLString:@"validUrl" delegate:nil];
}

- (void)test_cacheWithURLString_withNilUrlAndValidDelegate_shouldPass {
    NSObject<PNAPIClickCacherDelegate> *delegate = mockProtocol(@protocol(PNAPIClickCacherDelegate));
    PNAPIClickCacher *clickCacher = [[PNAPIClickCacher alloc] init];
    clickCacher.delegate = delegate;
    [clickCacher cacheWithURLString:nil delegate:delegate];
}

- (void)test_cacheWithURLString_withEmptyUrlAndValidDelegate_shouldPass {
    NSObject<PNAPIClickCacherDelegate> *delegate = mockProtocol(@protocol(PNAPIClickCacherDelegate));
    PNAPIClickCacher *clickCacher = [[PNAPIClickCacher alloc] init];
    clickCacher.delegate = delegate;
    [clickCacher cacheWithURLString:@"" delegate:delegate];
}

@end
