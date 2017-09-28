//
//  PNConfigRequestModel.h
//  sdk
//
//  Created by David Martin on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNConfigManager.h"

@interface PNConfigRequestModel : NSObject

@property (nonatomic, strong) NSString                          *appToken;
@property (nonatomic, strong) NSDictionary                      *extras;
@property (nonatomic, strong) NSObject<PNConfigManagerDelegate>   *delegate;

@end
