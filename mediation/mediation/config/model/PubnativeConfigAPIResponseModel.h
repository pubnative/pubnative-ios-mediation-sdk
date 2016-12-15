//
//  PubnativeConfigAPIResponseModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeJSONModel.h"
#import "PubnativeConfigModel.h"

@interface PubnativeConfigAPIResponseModel : PubnativeJSONModel

@property (nonatomic, strong) NSString              *status;
@property (nonatomic, strong) NSString              *error_message;
@property (nonatomic, strong) PubnativeConfigModel  *config;

- (BOOL)isSuccess;

@end
