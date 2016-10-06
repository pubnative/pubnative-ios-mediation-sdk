//
//  PubnativeDeliveryManager.h
//  mediation
//
//  Created by David Martin on 22/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PubnativeDeliveryManager : NSObject

// Pacing
+ (NSDate*)pacingDateForPlacementName:(NSString*)placementName;
+ (void)updatePacingDateForPlacementName:(NSString*)placementName;
+ (void)resetPacingDateForPlacementName:(NSString*)placementName;

// Impression
+ (void)logImpressionForPlacementName:(NSString *)placementName;
+ (NSInteger)dailyImpressionCountForPlacementName:(NSString *)placementName;
+ (NSInteger)hourlyImpressionCountForPlacementName:(NSString *)placementName;
+ (void)resetDailyImpressionCountForPlacementName:(NSString *)placementName;
+ (void)resetHourlyImpressionCountForPlacementName:(NSString *)placementName;

@end
