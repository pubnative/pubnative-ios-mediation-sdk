//
//  PNRequest.m
//  sdk
//
//  Created by David Martin on 31/03/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNHttpRequest.h"
#import "PNReachability.h"

NSInteger const STATUS_CODE_OK = 200;
NSTimeInterval const NETWORK_REQUEST_DEFAULT_TIMEOUT = 60;
NSURLRequestCachePolicy const NETWORK_REQUEST_DEFAULT_CACHE_POLICY = NSURLRequestUseProtocolCachePolicy;

@implementation PNHttpRequest

+ (void)requestWithURL:(NSString*)urlString andCompletionHandler:(PNHttpRequestBlock)completionHandler
{
    [self requestWithURL:urlString timeout:NETWORK_REQUEST_DEFAULT_TIMEOUT andCompletionHandler:completionHandler];
}

+ (void)requestWithURL:(NSString*)urlString timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PNHttpRequestBlock)completionHandler
{
    [self requestWithURL:urlString httpBody:nil timeout:timeoutInSeconds andCompletionHandler:completionHandler];
}

+ (void)requestWithURL:(NSString*)urlString httpBody:(NSData *)httpBody timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PNHttpRequestBlock)completionHandler
{
    if(!completionHandler){
        NSLog(@"PNHttpRequest - Error: delegate is null, dropping this request call");
        return;
    }
    
    if(!urlString) {
        NSError *requestError = [NSError errorWithDomain:@"PNHttpRequest - Error: url format error" code:0 userInfo:nil];
        [PNHttpRequest invokeBlock:completionHandler withResult:nil andError:requestError];
        return;
    }
    
    NSURL *requestURL = [NSURL URLWithString:urlString];
    if(!requestURL) {
        NSError *requestError = [NSError errorWithDomain:@"PNHttpRequest - Error: url format error" code:0 userInfo:nil];
        [PNHttpRequest invokeBlock:completionHandler withResult:nil andError:requestError];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NETWORK_REQUEST_DEFAULT_CACHE_POLICY
                                                       timeoutInterval:timeoutInSeconds];
    if (httpBody) {
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[httpBody length]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:httpBody];
    }
    
    PNReachability *reachability = [PNReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    if([reachability currentReachabilityStatus] == PNNetworkStatus_NotReachable){
        [reachability stopNotifier];
        NSError *internetError = [NSError errorWithDomain:@"PNHttpRequest - Error: internet not available" code:0 userInfo:nil];
        [PNHttpRequest invokeBlock:completionHandler withResult:nil andError:internetError];
    } else {
        [reachability stopNotifier];
        __block PNHttpRequestBlock completeBlock = [completionHandler copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                if(error) {
                    [PNHttpRequest invokeBlock:completeBlock withResult:nil andError:error];
                } else if(httpResponse.statusCode != STATUS_CODE_OK) {
                    NSString *statusCodeErrorString = [NSString stringWithFormat:@"PNHttpRequest - Error: response status code %ld error", (long)httpResponse.statusCode];
                    NSError *statusCodeError = [NSError errorWithDomain:statusCodeErrorString
                                                                   code:0
                                                               userInfo:nil];
                    [PNHttpRequest invokeBlock:completeBlock withResult:nil andError:statusCodeError];
                } else {
                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [PNHttpRequest invokeBlock:completeBlock withResult:result andError:nil];
                }
            }] resume];
            
        });
    }
}

#pragma mark Callback helper

+ (void)invokeBlock:(PNHttpRequestBlock)block withResult:(NSString*)result andError:(NSError*)error;
{
    if(block) {
        PNHttpRequestBlock invokeBlock = [block copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            invokeBlock(result, error);
        });
    }
}

-(NSString *_Nonnull)URLEncode: (NSString *)url {
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "] invertedSet];
    return [url stringByAddingPercentEncodingWithAllowedCharacters:set];
}

@end

