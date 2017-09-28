//
//  PNConfigAPIResponseModel.h
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"
#import "PNConfigModel.h"

@interface PNConfigAPIResponseModel : PNJSONModel

@property (nonatomic, strong) NSString          *status;
@property (nonatomic, strong) NSString          *error_message;
@property (nonatomic, strong) PNConfigModel  *config;

- (BOOL)isSuccess;

@end
