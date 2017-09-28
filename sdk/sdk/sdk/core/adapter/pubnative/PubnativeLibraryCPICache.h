//
//  PubnativeLibraryCPICache.h
//  sdk
//
//  Created by David Martin on 13/02/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNConfigModel.h"
#import "PNAPIAdModel.h"

extern NSString * const kCPICacheDidFinishLoadingNotification;

@interface PubnativeLibraryCPICache : NSObject

+ (void)initWithAppToken:(NSString*)appToken config:(PNConfigModel*)config;
+ (PNAPIAdModel*)get;

@end
