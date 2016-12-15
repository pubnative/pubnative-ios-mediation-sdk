//
//  PubnativeDeliveryManagerTest.m
//  mediation
//
//  Created by David Martin on 24/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PubnativeDeliveryManager.h"
#import <OCHamcrestIOS/OCHamcrestIOS.h>

NSString * const kPubnativeDeliveryManagerTestApptoken = @"apptoken";

@interface PubnativeDeliveryManagerTest : XCTestCase

@end

@implementation PubnativeDeliveryManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//// TODO: Pacing tests
//+ (NSDate*)pacingDateForPlacementName:(NSString*)placementName;
//+ (void)updatePacingDateForPlacementName:(NSString*)placementName;
//+ (void)resetPacingDateForPlacementName:(NSString*)placementName;

- (void)test_logImpressionForPlacementName_withValidPlacement_incrementsDailyCount
{
    NSInteger before = [PubnativeDeliveryManager dailyImpressionCountForPlacementName:@"apptoken"];
    [PubnativeDeliveryManager logImpressionForPlacementName:@"apptoken"];
    NSInteger after = [PubnativeDeliveryManager dailyImpressionCountForPlacementName:@"apptoken"];
    assertThatInteger(after, greaterThan([NSNumber numberWithInteger:before]));
}

- (void)test_logImpressionForPlacementName_withValidPlacement_incrementsHourlyCount
{
    NSInteger before = [PubnativeDeliveryManager hourlyImpressionCountForPlacementName:@"apptoken"];
    [PubnativeDeliveryManager logImpressionForPlacementName:@"apptoken"];
    NSInteger after = [PubnativeDeliveryManager hourlyImpressionCountForPlacementName:@"apptoken"];
    assertThatInteger(after, greaterThan([NSNumber numberWithInteger:before]));
}

- (void)test_logImpressionForPlacementName_withNilPlacement_shouldPass{
    
    [PubnativeDeliveryManager logImpressionForPlacementName:nil];
}

- (void)test_logImpressionForPlacementName_withEmptyPlacement_shouldPass{
    
    [PubnativeDeliveryManager logImpressionForPlacementName:@""];
}

- (void)test_dailyImpressionCountForPlacementName_withNilPlacement_shouldReturn0
{
    NSInteger value = [PubnativeDeliveryManager dailyImpressionCountForPlacementName:nil];
    assertThatInteger(value, equalToInteger(0));
}

- (void)test_hourlyImpressionCountForPlacementName_withNilPlacement_shouldReturn0
{
    NSInteger value = [PubnativeDeliveryManager hourlyImpressionCountForPlacementName:nil];
    assertThatInteger(value, equalToInteger(0));
}

- (void)test_dailyImpressionCountForPlacementName_withEmptyPlacement_shouldReturn0
{
    NSInteger value = [PubnativeDeliveryManager dailyImpressionCountForPlacementName:@""];
    assertThatInteger(value, equalToInteger(0));
}

- (void)test_hourlyImpressionCountForPlacementName_withEmptyPlacement_shouldReturn0
{
    NSInteger value = [PubnativeDeliveryManager hourlyImpressionCountForPlacementName:@""];
    assertThatInteger(value, equalToInteger(0));
}

- (void)test_resetDailyImpressionCountForPlacementName_withValidPlacement_shouldSet0
{
    [PubnativeDeliveryManager logImpressionForPlacementName:@"apptoken"];
    [PubnativeDeliveryManager resetDailyImpressionCountForPlacementName:@"apptoken"];
    NSInteger value = [PubnativeDeliveryManager dailyImpressionCountForPlacementName:@"apptoken"];
    assertThatInteger(value, equalToInteger(0));
}

- (void)test_resetHourlyImpressionCountForPlacementName_withValidPlacement_shouldSet0
{
    [PubnativeDeliveryManager logImpressionForPlacementName:@"apptoken"];
    [PubnativeDeliveryManager resetHourlyImpressionCountForPlacementName:@"apptoken"];
    NSInteger value = [PubnativeDeliveryManager hourlyImpressionCountForPlacementName:@"apptoken"];
    assertThatInteger(value, equalToInteger(0));
}

- (void)test_resetDailyImpressionCountForPlacementName_withNilPlacement_shouldPass
{
    [PubnativeDeliveryManager resetDailyImpressionCountForPlacementName:nil];
}

- (void)test_resetDailyImpressionCountForPlacementName_withEmptyPlacement_shouldPass
{
    [PubnativeDeliveryManager resetDailyImpressionCountForPlacementName:@""];
}

- (void)test_resetHourlyImpressionCountForPlacementName_withNilPlacement_shouldPass
{
    [PubnativeDeliveryManager resetHourlyImpressionCountForPlacementName:nil];
}

- (void)test_resetHourlyImpressionCountForPlacementName_withEmptyPlacement_shouldPass
{
    [PubnativeDeliveryManager resetHourlyImpressionCountForPlacementName:@""];
}



@end
