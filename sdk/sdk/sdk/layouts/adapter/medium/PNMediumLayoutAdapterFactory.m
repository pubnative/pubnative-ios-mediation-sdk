//
//  PNMediumLayoutAdapterFactory.m
//  sdk
//
//  Created by Can Soykarafakili on 19.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNMediumLayoutAdapterFactory.h"

@implementation PNMediumLayoutAdapterFactory

- (NSString *)factoryName
{
    return @"Medium";
}

+ (instancetype)sharedFactory
{
    static PNMediumLayoutAdapterFactory *_sharedFactory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFactory = [[PNMediumLayoutAdapterFactory alloc]init];
    });
    return _sharedFactory;
}

@end
