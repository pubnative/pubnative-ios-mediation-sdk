//
//  PNConfigManager.h
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNConfigModel.h"

@protocol PNConfigManagerDelegate <NSObject>

- (void)configDidFinishWithModel:(PNConfigModel*)model;

@end

@interface PNConfigManager : NSObject

+ (void)configWithAppToken:(NSString *)appToken
                    extras:(NSDictionary<NSString*, NSString*>*)extras
                  delegate:(NSObject<PNConfigManagerDelegate> *)delegate;
+ (void)reset;

@end
