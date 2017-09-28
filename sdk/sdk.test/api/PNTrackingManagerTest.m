//
//  PNAPITrackingManagerTest.m
//  sdk
//
//  Created by Can Soykarafakili on 03.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "PNAPITrackingManager.h"

@interface PNAPITrackingManagerTest : XCTestCase

@end

@implementation PNAPITrackingManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_trackWithURL_withNilUrl_shouldPass {
    [PNAPITrackingManager trackWithURL:nil];
}

- (void)test_trackWithURL_withNValidUrl_shouldPass {
    NSString *string = mock([NSString class]);
    string = @"validURL";
    [PNAPITrackingManager trackWithURL:[NSURL URLWithString:string]];
}
@end
