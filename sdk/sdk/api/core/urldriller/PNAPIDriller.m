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

#import "PNAPIDriller.h"

NSTimeInterval const kURLDrillerTimeout = 5; // seconds

@interface PNAPIDriller () <NSURLSessionTaskDelegate>

@property (nonatomic, weak)NSObject<PNAPIDrillerDelegate>  *delegate;
@property (nonatomic, strong)NSString                   *userAgent;
@property (nonatomic, strong)NSURL                      *url;
@property (nonatomic, strong)NSURL                      *lastURL;

@end

@implementation PNAPIDriller

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.delegate = nil;
    self.userAgent = nil;
    self.url = nil;
    self.lastURL = nil;
}

#pragma mark
#pragma mark URLDriller
#pragma mark

#pragma mark public

- (void)startDrillWithURLString:(NSString *)urlString delegate:(NSObject<PNAPIDrillerDelegate>*)delegate
{
    if(delegate == nil) {
        NSLog(@"Specified delegate is nil and required, this call will be drop");
    } else if (urlString == nil || urlString.length == 0) {
        NSLog(@"Specified urlString is nil or empty and required, this call will be drop");
    } else {
        
        self.delegate = delegate;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.userAgent == nil){
                UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *escapedPath = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                self.url = [NSURL URLWithString:escapedPath];
                
                [self invokeDidStartWithURL:self.url];
                if ([self isFinalURL:self.url]) {
                    [self invokeDidFinishWithURL:self.url];
                } else {
                    [self startDrill];
                }
            });
        });
    }
}

#pragma mark private

- (void)startDrill
{
    self.lastURL = self.url;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:kURLDrillerTimeout];
        
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *additionalHeadersDict = @{ @"User-Agent": self.userAgent };
    [sessionConfiguration setHTTPAdditionalHeaders:additionalHeadersDict];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self invokeDidFailWithURL:self.lastURL andError:error];
        } else {
            [self invokeDidFinishWithURL:response.URL];
        }
    }];
    
    [task resume];
    
}

- (BOOL)isFinalURL:(NSURL*)url
{
    BOOL result = NO;
    
    NSString *scheme = nil;
    if (url) {
        scheme = url.scheme;
    }
    if ([scheme isEqualToString:@"http"]
        || [scheme isEqualToString:@"itmss"]
        || [scheme isEqualToString:@"itms-apps"]
        || [scheme isEqualToString:@"itms-appss"]) {
        result = YES;
    }
    return result;
}


#pragma mark callback helpers

- (void)invokeDidFinishWithURL:(NSURL*)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishWithURL:)]){
            [self.delegate didFinishWithURL:url];
        }
    });
}

- (void)invokeDidFailWithURL:(NSURL*)url andError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFailWithURL:andError:)]){
            [self.delegate didFailWithURL:url andError:error];
        }
    });
}

- (void)invokeDidRedirectWithURL:(NSURL*)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didRedirectWithURL:)]){
            [self.delegate didRedirectWithURL:url];
        }
    });
}

- (void)invokeDidStartWithURL:(NSURL*)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didStartWithURL:)]){
            [self.delegate didStartWithURL:url];
        }
    });
}

#pragma mark
#pragma mark CALLBACKS
#pragma mark

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    [self invokeDidRedirectWithURL:request.URL];
    
    if ([self isFinalURL:request.URL]) {
        [self invokeDidFinishWithURL:request.URL];
    } else {
        completionHandler(request);
    }
}

@end
