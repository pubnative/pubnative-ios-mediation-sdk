//
//  PubnativeNetworkRequest.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeAdModel.h"

@class PubnativeNetworkRequest;

@protocol PubnativeNetworkRequestDelegate <NSObject>

-(void)pubnativeRequestDidStart:(PubnativeNetworkRequest *)request;
-(void)pubnativeRequest:(PubnativeNetworkRequest *)request didLoad:(PubnativeAdModel*)ad;
-(void)pubnativeRequest:(PubnativeNetworkRequest *)request didFail:(NSError*)error;

@end

@interface PubnativeNetworkRequest : NSObject

- (void)startWithAppToken:(NSString*)appToken
            placementName:(NSString*)placementName
                 delegate:(NSObject<PubnativeNetworkRequestDelegate>*)delegate;

- (void)setParameterWithKey:(NSString*)key
                      value:(NSString*)value;

- (void)setTargeting:(PubnativeAdTargetingModel *)targeting;
@end
