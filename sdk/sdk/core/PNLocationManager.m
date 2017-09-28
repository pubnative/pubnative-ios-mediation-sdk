//
//  PNAPILocationManager.m
//  library
//
//  Created by Alvarlega on 15/11/2016.
//  Copyright © 2016 PubNative. All rights reserved.
//

#import "PNLocationManager.h"

@interface PNLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation* lastKnownLocation;
@property (nonatomic, strong) CLLocationManager *manager;

@end

@implementation PNLocationManager

#pragma mark NSObject

+ (void)load
{
    [PNLocationManager requestLocation];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
    return self;
}

#pragma mark PNAPILocationManager

+ (instancetype)sharedInstance
{
    static PNLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PNLocationManager alloc] init];
    });
    return sharedInstance;
}

+ (void)requestLocation
{
    if([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedAlways
            || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            [[PNLocationManager sharedInstance].manager requestLocation];
        }
    }
}

+ (CLLocation *)getLocation
{
    [PNLocationManager requestLocation];
    return [PNLocationManager sharedInstance].lastKnownLocation;
}

#pragma mark - Callbacks -

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"PNAPILocationManager - Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.lastKnownLocation = locations.lastObject;
}

@end
