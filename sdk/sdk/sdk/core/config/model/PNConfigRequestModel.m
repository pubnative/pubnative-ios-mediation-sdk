//
//  PNConfigRequestModel.m
//  sdk
//
//  Created by David Martin on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNConfigRequestModel.h"

@implementation PNConfigRequestModel
- (void)dealloc
{
    self.appToken = nil;
    self.extras = nil;
    self.delegate = nil;
}
@end
