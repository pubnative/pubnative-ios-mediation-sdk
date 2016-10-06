//
//  PubnativeNetworkRequest.m
//  mediation
//
//  Created by David Martin on 31/03/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeHttpRequest.h"
#import "PubnativeReachability.h"

NSInteger const STATUS_CODE_OK = 200;
NSTimeInterval const NETWORK_REQUEST_DEFAULT_TIMEOUT = 60;
NSURLRequestCachePolicy const NETWORK_REQUEST_DEFAULT_CACHE_POLICY = NSURLRequestUseProtocolCachePolicy;

@implementation PubnativeHttpRequest

+ (void)requestWithURL:(NSString*)urlString andCompletionHandler:(PubnativeHttpRequestBlock)completionHandler
{
    [self requestWithURL:urlString timeout:NETWORK_REQUEST_DEFAULT_TIMEOUT andCompletionHandler:completionHandler];
}

+ (void)requestWithURL:(NSString*)urlString timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PubnativeHttpRequestBlock)completionHandler
{
    [self requestWithURL:urlString httpBody:nil timeout:timeoutInSeconds andCompletionHandler:completionHandler];
}

+ (void)requestWithURL:(NSString*)urlString httpBody:(NSData *)httpBody timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PubnativeHttpRequestBlock)completionHandler
{
    if(completionHandler){
        
        if(urlString && urlString.length > 0) {
            NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if(requestURL) {
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
                
                PubnativeReachability *reachability = [PubnativeReachability reachabilityForInternetConnection];
                [reachability startNotifier];
                if([reachability currentReachabilityStatus] == PubnativeNetworkStatus_NotReachable){
                    NSError *internetError = [NSError errorWithDomain:@"PubnativeHttpRequest - Error: internet not available" code:0 userInfo:nil];
                    [PubnativeHttpRequest invokeBlock:completionHandler withResult:nil andError:internetError];
                } else {
                    __block PubnativeHttpRequestBlock completeBlock = [completionHandler copy];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        [NSURLConnection sendAsynchronousRequest:request
                                                           queue:[NSOperationQueue mainQueue]
                                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                         {
                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                             if(error) {
                                 [PubnativeHttpRequest invokeBlock:completeBlock withResult:nil andError:error];
                             } else if(httpResponse.statusCode != STATUS_CODE_OK) {
                                 NSString *statusCodeErrorString = [NSString stringWithFormat:@"PubnativeHttpRequest - Error: response status code %ld error", (long)httpResponse.statusCode];
                                 NSError *statusCodeError = [NSError errorWithDomain:statusCodeErrorString
                                                                                code:0
                                                                            userInfo:nil];
                                 [PubnativeHttpRequest invokeBlock:completeBlock withResult:nil andError:statusCodeError];
                             } else {
                                 NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                 [PubnativeHttpRequest invokeBlock:completeBlock withResult:result andError:nil];
                             }
                         }];
                    });
                }
            } else {
                NSError *requestError = [NSError errorWithDomain:@"PubnativeHttpRequest - Error: url format error" code:0 userInfo:nil];
                [PubnativeHttpRequest invokeBlock:completionHandler withResult:nil andError:requestError];
            }
        } else {
            NSError *parameterError = [NSError errorWithDomain:@"PubnativeHttpRequest - Error: url format error" code:0 userInfo:nil];
            [PubnativeHttpRequest invokeBlock:completionHandler withResult:nil andError:parameterError];
        }
    } else {
        NSLog(@"PubnativeHttpRequest - Error: delegate is null, dropping this request call");
    }
}

#pragma mark Callback helper

+ (void)invokeBlock:(PubnativeHttpRequestBlock)block withResult:(NSString*)result andError:(NSError*)error;
{
    if(block) {
        PubnativeHttpRequestBlock invokeBlock = [block copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            invokeBlock(result, error);
        });
    }
}

@end
