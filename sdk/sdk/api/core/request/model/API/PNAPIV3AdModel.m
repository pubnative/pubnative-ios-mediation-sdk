//
//  Copyright © 2016 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNAPIV3AdModel.h"

@implementation PNAPIV3AdModel

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.link = nil;
    self.assets = nil;
    self.meta = nil;
    self.beacons = nil;
}

#pragma mark
#pragma mark PNAPIV3BaseModel
#pragma mark

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.link = dictionary[@"link"];
        self.assetgroupid = dictionary[@"assetgroupid"];
        self.assets = [PNAPIV3DataModel parseArrayValues:dictionary[@"assets"]];
        self.meta = [PNAPIV3DataModel parseArrayValues:dictionary[@"meta"]];
        self.beacons = [PNAPIV3DataModel parseArrayValues:dictionary[@"beacons"]];;
    }
    return self;
}

#pragma mark
#pragma mark PubnativeAPIV3AdModel
#pragma mark
#pragma mark public

- (PNAPIV3DataModel*)assetWithType:(NSString *)type
{
    PNAPIV3DataModel *result = nil;
    result = [self dataWithType:type fromList:self.assets];
    return result;
}

- (PNAPIV3DataModel*)metaWithType:(NSString *)type
{
    PNAPIV3DataModel *result = nil;
    result = [self dataWithType:type fromList:self.meta];
    return result;
}

- (NSArray*)beaconsWithType:(NSString*)type;
{
    NSArray *result = nil;
    result = [self allWithType:type fromList:self.beacons];
    return result;
}

#pragma mark private

- (PNAPIV3DataModel*)dataWithType:(NSString*)type
                         fromList:(NSArray*)list
{
    PNAPIV3DataModel *result = nil;
    if (list != nil) {
        for (PNAPIV3DataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                result = data;
                break;
            }
        }
    }
    return result;
}

- (NSArray*)allWithType:(NSString *)type
               fromList:(NSArray*)list
{
    NSMutableArray *result = nil;
    if (list != nil) {
        for (PNAPIV3DataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                if (result == nil) {
                    result = [[NSMutableArray alloc] init];
                }
                [result addObject:data];
            }
        }
    }
    return result;
}

@end
