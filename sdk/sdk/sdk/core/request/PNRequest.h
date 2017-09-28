//
//  PNRequest.h
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAdModel.h"

@class PNRequest;

@protocol PNRequestDelegate <NSObject>

-(void)pubnativeRequestDidStart:(PNRequest *)request;
-(void)pubnativeRequest:(PNRequest *)request didLoad:(PNAdModel*)ad;
-(void)pubnativeRequest:(PNRequest *)request didFail:(NSError*)error;

@end

@interface PNRequest : NSObject

/**
 * Sets the option to enable/disable resource caching from the SDK, 
 * so all assets will be downloaded before serving the ad,
 * Default value YES
 */
@property (nonatomic, assign)BOOL cacheResources;

/**
 * Starts a request given the parametes
 * @param appToken value given in the PubNative's dashboard
 * @param placementName value given in the PubNative's dashboard for this specific requested placement
 * @param delegate delegate where to receive callbacks from the request
 */
- (void)startWithAppToken:(NSString*)appToken
            placementName:(NSString*)placementName
                 delegate:(NSObject<PNRequestDelegate>*)delegate;

/**
 * Inject extra data in each request
 * @param key string to be added as a key to extra request parameters
 * @param value string to be added as a value to extra request parameters for the given key
 */
- (void)addParameterWithKey:(NSString*)key
                      value:(NSString*)value;

@end
