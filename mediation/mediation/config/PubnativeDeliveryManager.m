//
//  PubnativeDeliveryManager.m
//  mediation
//
//  Created by David Martin on 22/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeDeliveryManager.h"

NSString * const kPubnativeDeliveryManagerImpressionCountDayKey = @"_day_count";
NSString * const kPubnativeDeliveryManagerImpressionCountHourKey = @"_hour_count";
NSString * const kPubnativeDeliveryManagerImpressionLastUpdateKey = @"_last_update";

@interface PubnativeDeliveryManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSDate*> *currentPacing;

@end

@implementation PubnativeDeliveryManager

+ (PubnativeDeliveryManager*)getSharedManager
{
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Pacing

+ (NSDate*)pacingDateForPlacementName:(NSString*)placementName;
{
    NSDate *result = nil;
    if([self getSharedManager].currentPacing) {
        result = [[self getSharedManager].currentPacing objectForKey:placementName];
    }
    return result;
}

+ (void)updatePacingDateForPlacementName:(NSString*)placementName
{
    if ([self getSharedManager].currentPacing == nil) {
        [self getSharedManager].currentPacing = [NSMutableDictionary dictionary];
    }
    
    [[self getSharedManager].currentPacing setObject:[NSDate date]
                                              forKey:placementName];
}

+ (void)resetPacingDateForPlacementName:(NSString*)placementName
{
    if ([self getSharedManager].currentPacing) {
        [[self getSharedManager].currentPacing removeObjectForKey:placementName];
    }
}

#pragma mark Impression

+ (void)logImpressionForPlacementName:(NSString *)placementName
{
    NSLog(@"logImpressionForPlacementName:%@", placementName);
    NSInteger dayCount = [self dailyImpressionCountForPlacementName:placementName];
    [self setImpressionCountForPlacementName:placementName
                                        type:kPubnativeDeliveryManagerImpressionCountDayKey
                                       value:dayCount+1];
    
    NSInteger hourCount = [self hourlyImpressionCountForPlacementName:placementName];
    [self setImpressionCountForPlacementName:placementName
                                        type:kPubnativeDeliveryManagerImpressionCountHourKey
                                       value:hourCount+1];
}

+ (NSInteger)dailyImpressionCountForPlacementName:(NSString *)placementName
{
    return [self impressionCountForPlacementName:placementName
                                            type:kPubnativeDeliveryManagerImpressionCountDayKey];
}

+ (NSInteger)hourlyImpressionCountForPlacementName:(NSString *)placementName
{
    return [self impressionCountForPlacementName:placementName
                                            type:kPubnativeDeliveryManagerImpressionCountHourKey];;
}

+ (void)resetDailyImpressionCountForPlacementName:(NSString *)placementName
{
    [self setImpressionCountForPlacementName:placementName
                                        type:kPubnativeDeliveryManagerImpressionCountDayKey
                                       value:0];
}

+ (void)resetHourlyImpressionCountForPlacementName:(NSString *)placementName
{
    [self setImpressionCountForPlacementName:placementName
                                        type:kPubnativeDeliveryManagerImpressionCountHourKey
                                       value:0];
}

#pragma mark -
#pragma mark PRIVATE
#pragma mark -

#pragma mark Pacing cap

+ (void)setLastImpressionUpdateForPlacementName:(NSString*)placementName
                                           date:(NSDate*)date
{
    if(placementName
       && placementName.length > 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", placementName, kPubnativeDeliveryManagerImpressionLastUpdateKey];
        if(date){
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:[date timeIntervalSince1970]]
                                                      forKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
    }
}

+ (NSDate*)lastImpressionUpadteForPlacementName:(NSString*)placementName
{
    NSDate *result = nil;
    if(placementName && placementName.length > 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", placementName, kPubnativeDeliveryManagerImpressionLastUpdateKey];
        NSNumber *timeInterval = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if(timeInterval) {
            result = [NSDate dateWithTimeIntervalSince1970:[timeInterval doubleValue]];
        }
    }
    return result;
}

#pragma mark Impression cap

+ (void)setImpressionCountForPlacementName:(NSString*)placementName
                                      type:(NSString*)type
                                     value:(NSInteger)value
{
    if(type
       && type.length > 0
       && placementName
       && placementName.length > 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", placementName, type];
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    }
}

+ (NSInteger)impressionCountForPlacementName:(NSString*)placementName
                                        type:(NSString*)type
{
    [self updateImpressionCountForPlacementName:placementName];
    NSInteger result = 0;
    if(type
       && type.length > 0
       && placementName
       && placementName.length > 0){
       
        NSString *key = [NSString stringWithFormat:@"%@%@", placementName, type];
        result = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        
    }
    return result;
}

+ (void)updateImpressionCountForPlacementName:(NSString*)placementName
{
    if(placementName && placementName.length > 0){
        
        NSDate *lastUpdate = [self lastImpressionUpadteForPlacementName:placementName];
        if(lastUpdate) {
            NSDateComponents *lastUpdateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay|NSCalendarUnitHour)
                                                                                     fromDate:lastUpdate];
            
            NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay|NSCalendarUnitHour)
                                                                                  fromDate:[NSDate date]];
            
            NSInteger lastUpdateDay = [lastUpdateComponents day];
            NSInteger currentDay = [currentComponents day];
            if(lastUpdateDay != currentDay) {
                [self setImpressionCountForPlacementName:placementName
                                                    type:kPubnativeDeliveryManagerImpressionCountDayKey
                                                   value:0];
                [self setImpressionCountForPlacementName:placementName
                                                    type:kPubnativeDeliveryManagerImpressionCountHourKey
                                                   value:0];
            } else {
                
                NSInteger lastUpdateHour = [lastUpdateComponents hour];
                NSInteger currentUpdateHour = [currentComponents hour];
                if(lastUpdateHour != currentUpdateHour){
                    [self setImpressionCountForPlacementName:placementName
                                                        type:kPubnativeDeliveryManagerImpressionCountHourKey
                                                       value:0];
                }
            }
        }
        [self setLastImpressionUpdateForPlacementName:placementName date:[NSDate date]];
    }
}


@end
