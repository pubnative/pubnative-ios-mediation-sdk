//
//  PubnativeLibraryCPICacheItem.m
//  sdk
//
//  Created by David Martin on 13/02/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PubnativeLibraryCPICacheItem.h"

@implementation PubnativeLibraryCPICacheItem

- (instancetype)initWithAd:(PNAPIAdModel*)ad
{
    self = [self init];
    if (self) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
        self.ad = ad;
    }
    return self;
}

@end
