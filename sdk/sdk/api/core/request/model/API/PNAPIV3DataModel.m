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

#import "PNAPIV3DataModel.h"

@implementation PNAPIV3DataModel

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.type = nil;
    self.data = nil;
}

#pragma mark
#pragma mark PNAPIV3BaseModel
#pragma mark

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.type = dictionary[@"type"];
        self.data = dictionary[@"data"];
    }
    return self;
}

#pragma mark
#pragma mark PNAPIV3DataModel
#pragma mark
#pragma mark public
- (NSString*)text
{
    return (NSString*)[self dataWithKey:@"text"];
}

- (NSString*)vast
{
    return (NSString*)[self dataWithKey:@"vast2"];
}

- (NSString*)tracking
{
    return (NSString*)[self dataWithKey:@"tracking"];
}

- (NSNumber*)number
{
    return (NSNumber*)[self dataWithKey:@"number"];
}

- (NSString*)url
{
    return (NSString*)[self dataWithKey:@"url"];
}

- (NSString *)html
{
    return (NSString*)[self dataWithKey:@"html"];
}

- (NSString*)stringFieldWithKey:(NSString*)key
{
    return (NSString*) [self dataWithKey:key];
}

- (NSNumber*)numberFieldWithKey:(NSString*)key
{
    return (NSNumber*) [self dataWithKey:key];
}

- (NSObject*)dataWithKey:(NSString*)key
{
    NSObject *result = nil;
    if (self.data != nil && [self.data objectForKey:key]) {
        result = [self.data objectForKey:key];
    }
    return result;
}

@end
