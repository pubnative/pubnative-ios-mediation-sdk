//
//  Pubnative.m
//  sdk
//
//  Created by David Martin on 10/02/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "Pubnative.h"
#import "PNConfigManager.h"
#import "PNSettings.h"

@implementation Pubnative

+ (void)setCoppa:(BOOL)enabled
{
    [PNSettings sharedInstance].coppa = enabled;
}

+ (void)setTargeting:(PNAdTargetingModel*)targeting
{
    [PNSettings sharedInstance].targeting = targeting;
}

+ (void)setTestMode:(BOOL)enabled
{
    [PNSettings sharedInstance].test = enabled;
}

+ (void)initWithAppToken:(NSString*)appToken
{
    // TODO: Use coppa mode in deep when the cache is built
    if (appToken == nil || appToken.length == 0) {
        NSLog(@"PubNative - app token is nil or empty and required, dropping this call");
    } else {
        [PNConfigManager configWithAppToken:appToken
                                     extras:[[PNSettings sharedInstance].targeting toDictionary]
                                   delegate:nil];
    }
}

@end
