//
//  PNSettings.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNSettings.h"
#import "PNLocationManager.h"

@interface PNSettings ()

@property (nonatomic, readonly) NSString *idfa;

@end

@implementation PNSettings

- (void)dealloc
{
    self.targeting = nil;
    self.os = nil;
    self.osVersion = nil;
    self.deviceName = nil;
    self.locale = nil;
    self.sdkVersion = nil;
    self.appBundleID = nil;
    self.appVersion = nil;
}

- (BOOL)needsFill
{
    return self.os == nil;
}

+ (PNSettings*)sharedInstance
{
    static PNSettings* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNSettings alloc] init];
    });
    return _instance;
}

- (NSString*)advertisingId
{
    NSString *result = nil;
    if(!self.coppa && NSClassFromString(@"ASIdentifierManager")){
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            result = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    return result;
}

- (CLLocation *)location
{
    CLLocation *result = nil;
    if(!self.coppa) {
        result = [PNLocationManager getLocation];
    }
    return result;
}

- (void)fillDefaults
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    self.os = currentDevice.systemName;
    self.osVersion = currentDevice.systemVersion;
    self.deviceName = currentDevice.model;
    self.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    
//    self.sdkVersion = // TODO: GET SDK/VERSION
    self.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.appBundleID = [[NSBundle mainBundle] bundleIdentifier];
}

@end
