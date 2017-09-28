//
//  PNAPILocationManager.h
//  library
//
//  Created by Alvarlega on 15/11/2016.
//  Copyright © 2016 PubNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PNLocationManager : NSObject

+ (CLLocation*)getLocation;

@end
