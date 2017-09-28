//
//  PNLayoutAdapterFactory.m
//  sdk
//
//  Created by Can Soykarafakili on 19.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayoutAdapterFactory.h"

@implementation PNLayoutAdapterFactory

- (PNLayoutAdapter*)adapterWithName:(NSString*)adapterName
{
    PNLayoutAdapter *adapter = nil;
    if (adapterName == nil || [adapterName length] == 0) {
        NSLog(@"PNNetworkAdapterFactory.createApdaterWithNetwork - Invalid adapter name");
    } else {
        NSString *className = [NSString stringWithFormat:@"%@%@", self.factoryName, adapterName];
        Class adapterClass = NSClassFromString(className);
        if (adapterClass && [adapterClass isSubclassOfClass:[PNLayoutAdapter class]]) {
            adapter = [[adapterClass alloc] init];
        } else {
            NSLog(@"PNLayoutAdapterFactory.createApdaterWithNetwork - Adapter not available");
        }
    }
    return adapter;
}

- (NSString *)factoryName
{
    return nil;
}

+ (instancetype)sharedFactory
{
    return nil;
}

@end
