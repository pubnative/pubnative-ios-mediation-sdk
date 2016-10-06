//
//  PubnativeAdapterFactory.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapterFactory.h"

@implementation PubnativeNetworkAdapterFactory

+ (PubnativeNetworkAdapter *)createApdaterWithAdapterName:(NSString*)adapterName
{
    PubnativeNetworkAdapter *adapter = nil;
    if (adapterName == nil || [adapterName length] == 0) {
        NSLog(@"PubnativeNetworkAdapterFactory.createApdaterWithNetwork - Invalid adapter name");
    } else {
        Class adapterClass = NSClassFromString(adapterName);
        if (adapterClass && [adapterClass isSubclassOfClass:[PubnativeNetworkAdapter class]]) {
            adapter = [[adapterClass alloc] init];
        } else {
            NSLog(@"PubnativeNetworkAdapterFactory.createApdaterWithNetwork - Adapter not available");
        }
    }
    return adapter;
}

@end
