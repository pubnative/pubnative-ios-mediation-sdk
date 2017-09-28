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

#import "PNAPIClickCacher.h"
#import "PNAPIDriller.h"

@interface PNAPIClickCacher ()<PNAPIDrillerDelegate>

@property(nonatomic, weak)NSObject<PNAPIClickCacherDelegate> *delegate;

@end

@implementation PNAPIClickCacher

- (void)cacheWithURLString:(NSString *)urlString delegate:(NSObject<PNAPIClickCacherDelegate> *)delegate
{
    self.delegate = delegate;
    [[[PNAPIDriller alloc] init] startDrillWithURLString:urlString delegate:self];
}

- (void)invokeDidFinishWithURL:(NSURL*)url
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCacherDidFinishWithURL:)]) {
        [self.delegate clickCacherDidFinishWithURL:[url absoluteString]];
    }
}

- (void)didStartWithURL:(NSURL*)url
{
    // Do nothing
}

- (void)didRedirectWithURL:(NSURL*)url
{
    // Do nothing
}

- (void)didFinishWithURL:(NSURL*)url
{
    [self invokeDidFinishWithURL:url];
}

- (void)didFailWithURL:(NSURL*)url andError:(NSError*)error
{
    [self invokeDidFinishWithURL:url];
}

@end
