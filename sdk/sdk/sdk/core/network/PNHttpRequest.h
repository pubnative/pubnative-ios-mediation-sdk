//
//  PNRequest.h
//  sdk
//
//  Created by David Martin on 31/03/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PNHttpRequestBlock)(NSString *result, NSError *error);

@interface PNHttpRequest : NSObject

+ (void)requestWithURL:(NSString*)urlString andCompletionHandler:(PNHttpRequestBlock)completionHandler;
+ (void)requestWithURL:(NSString*)urlString timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PNHttpRequestBlock)completionHandler;
+ (void)requestWithURL:(NSString*)urlString httpBody:(NSData*)httpBody timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PNHttpRequestBlock)completionHandler;

@end
