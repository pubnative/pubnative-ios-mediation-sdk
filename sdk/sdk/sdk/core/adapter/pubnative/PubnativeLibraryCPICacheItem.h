//
//  PubnativeLibraryCPICacheItem.h
//  sdk
//
//  Created by David Martin on 13/02/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAPIAdModel.h"

@interface PubnativeLibraryCPICacheItem : NSObject

@property (nonatomic, assign) NSTimeInterval    timestamp;
@property (nonatomic, strong) PNAPIAdModel         *ad;

- (instancetype)initWithAd:(PNAPIAdModel*)ad;

@end
