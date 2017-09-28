//
//  PNInsightsManagerTest.m
//  sdk
//
//  Created by Can Soykarafakili on 03.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "PNInsightsManager.h"
#import "PNInsightDataModel.h"
@interface PNInsightsManagerTest : XCTestCase

@end

@implementation PNInsightsManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_trackDataWithUrl_withNilUrl_shouldPass {
    PNInsightDataModel *model = mock([PNInsightDataModel class]);
    [PNInsightsManager trackDataWithUrl:@"" parameters:nil data:model];
}

- (void)test_trackDataWithUrl_withEmptyUrl_shouldPass {
    PNInsightDataModel *model = mock([PNInsightDataModel class]);
    [PNInsightsManager trackDataWithUrl:@"" parameters:nil data:model];
}

- (void)test_trackDataWithUrl_withNilData_shouldPass {
    [PNInsightsManager trackDataWithUrl:@"validTrackUrl" parameters:nil data:nil];
}

- (void)test_trackDataWithUrl_withValidDataAndValidUrl_shouldPass {
    PNInsightDataModel *model = mock([PNInsightDataModel class]);
    [PNInsightsManager trackDataWithUrl:@"validTrackUrl" parameters:nil data:model];
}
@end
