//
//  PubnativeConfigManager.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeConfigModel.h"

@protocol PubnativeConfigManagerDelegate <NSObject>

- (void)configDidFinishWithModel:(PubnativeConfigModel*)model;

@end

@interface PubnativeConfigManager : NSObject

+ (void)configWithAppToken:(NSString *)appToken
                    extras:(NSDictionary<NSString*, NSString*>*)extras
                  delegate:(NSObject<PubnativeConfigManagerDelegate> *)delegate;
+ (void)reset;

@end
