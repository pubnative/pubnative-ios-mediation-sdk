//
//  PNError.h
//  sdk
//
//  Created by David Martin on 30/11/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PNError_adapter_timeout,
    PNError_adapter_illegalArguments,
    PNError_adapter_noFill,
    PNError_layout_invalidParameters
} PNErrorCode;


@interface PNError : NSError

+ (PNError*)errorWithCode:(PNErrorCode)code;

@end
