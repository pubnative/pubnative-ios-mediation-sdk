//
//  PubnativeConfigUtils.m
//  mediation
//
//  Created by David Martin on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeResourceUtils.h"

@implementation PubnativeResourceUtils

+ (NSString*)getStringFromJSONFile:(NSString*)file
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [NSString stringWithContentsOfFile:[testBundle pathForResource:file ofType:@"json"]
                                 usedEncoding:nil
                                        error:nil];
}


+ (NSDictionary*)getDictionaryFromJSONFile:(NSString*)file
{
    NSString *jsonString = [self getStringFromJSONFile:file];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonDictionary;
}

@end
