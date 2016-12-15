//
//  PubnativeConfigRequestModel.h
//  mediation
//
//  Created by David Martin on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeConfigManager.h"

@interface PubnativeConfigRequestModel : NSObject

@property (nonatomic, strong) NSString                                  *appToken;
@property (nonatomic, strong) NSDictionary                              *extras;
@property (nonatomic, strong) NSObject<PubnativeConfigManagerDelegate>  *delegate;

@end
