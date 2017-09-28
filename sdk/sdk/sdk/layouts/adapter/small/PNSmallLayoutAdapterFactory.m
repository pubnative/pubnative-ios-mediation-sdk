//
//  PNSmallLayoutAdapterFactory.h
//  sdk
//
//  Created by Can Soykarafakili on 14.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNSmallLayoutAdapterFactory.h"

@implementation PNSmallLayoutAdapterFactory

- (NSString *)factoryName
{
    return @"Small";
}

+ (instancetype)sharedFactory
{
    static PNSmallLayoutAdapterFactory *_sharedFactory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFactory = [[PNSmallLayoutAdapterFactory alloc]init];
    });
    return _sharedFactory;
}

@end
