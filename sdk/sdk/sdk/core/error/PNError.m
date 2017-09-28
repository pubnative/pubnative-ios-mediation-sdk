//
//  PNError.m
//  sdk
//
//  Created by David Martin on 30/11/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNError.h"

@implementation PNError

+ (PNError *)errorWithCode:(PNErrorCode)code
{
    return [PNError errorWithDomain:@"Internal mediation error happened, please check error codes in PNError class" code:code userInfo:nil];
}

@end
