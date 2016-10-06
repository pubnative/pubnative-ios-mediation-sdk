//
//  PubnativeNetworkRequest.h
//  mediation
//
//  Created by David Martin on 31/03/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PubnativeHttpRequestBlock)(NSString *result, NSError *error);

@interface PubnativeHttpRequest : NSObject

+ (void)requestWithURL:(NSString*)urlString andCompletionHandler:(PubnativeHttpRequestBlock)completionHandler;
+ (void)requestWithURL:(NSString*)urlString timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PubnativeHttpRequestBlock)completionHandler;
+ (void)requestWithURL:(NSString*)urlString httpBody:(NSData*)httpBody timeout:(NSTimeInterval)timeoutInSeconds andCompletionHandler:(PubnativeHttpRequestBlock)completionHandler;

@end
