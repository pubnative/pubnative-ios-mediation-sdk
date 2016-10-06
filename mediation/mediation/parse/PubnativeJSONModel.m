//
//  PubnativeJSONModel.m
//  mediation
//
//  Created by David Martin on 05/04/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeJSONModel.h"

@interface PubnativeJSONModel ()

@property (nonatomic, strong)NSDictionary *jsonDictionary;

@end

@implementation PubnativeJSONModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
{
    self = [super init];
    if(self) {
        self.jsonDictionary = dictionary;
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    return [((PubnativeJSONModel*)[[self class] alloc]) initWithDictionary:dictionary];
}

+ (NSDictionary*)parseDictionaryValues:(NSDictionary*)dictionary;
{
    NSMutableDictionary *result;
    if(dictionary) {
        result = [NSMutableDictionary dictionary];
        for (id key in [dictionary allKeys]) {
            
            NSDictionary *valueDictionary = dictionary[key];
            NSObject *value = [[self alloc] initWithDictionary:valueDictionary];
            [result setObject:value forKey:key];
        }
    }
    return result;
}

+ (NSArray*)parseArrayValues:(NSArray*)array;
{
    NSMutableArray *result;
    if(array) {
        result = [NSMutableArray array];
        for (NSDictionary* valueDictionary in array) {
            NSObject *value = [[self alloc] initWithDictionary:valueDictionary];
            [result addObject:value];
        }
    }
    return result;
}

- (NSDictionary *)toDictionary
{
    return self.jsonDictionary;
}

@end
