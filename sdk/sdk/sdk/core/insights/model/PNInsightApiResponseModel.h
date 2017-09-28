//
//  PNInsightApiResponseModel.h
//  sdk
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"

@interface PNInsightApiResponseModel : PNJSONModel

@property (nonatomic, strong) NSString              *status;
@property (nonatomic, strong) NSString              *error_message;

- (BOOL)isSuccess;

@end

