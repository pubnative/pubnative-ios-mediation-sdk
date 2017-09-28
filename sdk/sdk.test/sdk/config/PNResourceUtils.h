//
//  PNConfigUtils.h
//  sdk
//
//  Created by David Martin on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNConfigModel.h"

@interface PNResourceUtils : NSObject

+ (NSDictionary*)getDictionaryFromJSONFile:(NSString*)file;

@end
