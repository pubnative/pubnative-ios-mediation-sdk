//
//  PNLargeLayoutAdapterFactory.m
//  sdk
//
//  Created by Can Soykarafakili on 04.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLargeLayoutAdapterFactory.h"

@implementation PNLargeLayoutAdapterFactory

- (NSString *)factoryName
{
    return @"Large";
}

+ (instancetype)sharedFactory
{
    static PNLargeLayoutAdapterFactory *_sharedFactory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFactory = [[PNLargeLayoutAdapterFactory alloc]init];
    });
    return _sharedFactory;
}

@end
