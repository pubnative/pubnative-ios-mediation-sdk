//
//  PubnativeAdapterFactory.m
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNNetworkAdapterFactory.h"

@implementation PNNetworkAdapterFactory

+ (PNNetworkAdapter *)createApdaterWithAdapterName:(NSString*)adapterName
{
    PNNetworkAdapter *adapter = nil;
    if (adapterName == nil || [adapterName length] == 0) {
        NSLog(@"PNNetworkAdapterFactory.createApdaterWithNetwork - Invalid adapter name");
    } else {
        Class adapterClass = NSClassFromString(adapterName);
        if (adapterClass && [adapterClass isSubclassOfClass:[PNNetworkAdapter class]]) {
            adapter = [[adapterClass alloc] init];
        } else {
            NSLog(@"PNNetworkAdapterFactory.createApdaterWithNetwork - Adapter not available");
        }
    }
    return adapter;
}

@end
