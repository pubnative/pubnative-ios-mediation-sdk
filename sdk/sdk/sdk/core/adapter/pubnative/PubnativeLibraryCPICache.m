//
//  PubnativeLibraryCPICache.m
//  sdk
//
//  Created by David Martin on 13/02/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PubnativeLibraryCPICache.h"
#import "PNAPIRequestParameter.h"
#import "PubnativeLibraryCPICacheItem.h"
#import "PNAPIRequest.h"

NSString * const kCPICacheDidFinishLoadingNotification = @"PubnativeLibraryCPICache.didFinishLoading";
NSUInteger const kCPICacheDefaultMinSize = 2; // Min amount of ads in the cache before requesting to fill
NSTimeInterval const kCPICacheDefaultThreshold = 3600; // In seconds (60 mins)
BOOL const kCPICacheDefaultEnabled = false;

@interface PubnativeLibraryCPICache () <PNAPIRequestDelegate>

@property (nonatomic, strong)NSMutableArray *cacheQueue;
@property (nonatomic, strong)PNAPIRequest      *currentRequest;
@property (nonatomic, strong)NSString       *appToken;
@property (nonatomic, strong)NSDictionary   *requestParameters;

// Accessors
@property (nonatomic, assign)NSUInteger     cacheMinSize;
@property (nonatomic, assign)NSTimeInterval cacheThreshold;  // In seconds
@property (nonatomic, assign)BOOL           enabled;

@end

@implementation PubnativeLibraryCPICache

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheMinSize = kCPICacheDefaultMinSize;
        self.cacheThreshold = kCPICacheDefaultThreshold;
        self.enabled = kCPICacheDefaultEnabled;
    }
    return self;
}

- (void)dealloc
{
    self.cacheQueue = nil;
    self.currentRequest = nil;
    self.appToken = nil;
    self.requestParameters = nil;
}

+ (instancetype)sharedInstance
{
    static id _sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[PubnativeLibraryCPICache alloc] init];
    });
    return _sharedInstance;
}

+ (void)initWithAppToken:(NSString*)appToken config:(PNConfigModel*)config
{
    if (![PubnativeLibraryCPICache idle]) {
        NSLog(@"PubNative CPI cache - currently in use, dropping this call");
        [PubnativeLibraryCPICache invokeDidFinishLoading];
    } else if (appToken == nil || appToken.length == 0) {
        NSLog(@"PubNative CPI cache - app token is null or empty and required, dropping this call");
        [PubnativeLibraryCPICache invokeDidFinishLoading];
    } else if (config == nil || config.isEmpty) {
        NSLog(@"PubNative CPI cache - model is null or empty and required, dropping this call");
        [PubnativeLibraryCPICache invokeDidFinishLoading];
    } else if ([PubnativeLibraryCPICache cacheSizeCritical]) {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //  1. PARAMETERS
        parameters[PNAPIRequestParameter.appToken] = appToken;
        if(config.ad_cache_params != nil) {
            [parameters addEntriesFromDictionary:config.ad_cache_params];
        }
        [PubnativeLibraryCPICache sharedInstance].requestParameters = parameters;
        
        // 2. CACHE MIN SIZE
        NSNumber *cacheMinSize = (NSNumber*) config.globals[PN_CONFIG_GLOBAL_KEY_CPI_CACHE_MIN_SIZE];
        if (cacheMinSize != nil) {
            [PubnativeLibraryCPICache sharedInstance].cacheMinSize = [cacheMinSize unsignedIntegerValue];
        }
        
        // 3. CACHE VALID THRESHOLD
        NSNumber *cacheThreshold = (NSNumber*) config.globals[PN_CONFIG_GLOBAL_KEY_CPI_CACHE_REFRESH];
        if (cacheThreshold != nil) {
            [PubnativeLibraryCPICache sharedInstance].cacheThreshold = [cacheThreshold doubleValue] * 60; // From minutes to seconds
        }

        // 4. CACHE ENABLE/DISABLE
        NSNumber *enabled = (NSNumber*) config.globals[PN_CONFIG_GLOBAL_KEY_CPI_CACHE_ENABLED];
        if (enabled != nil) {
            [PubnativeLibraryCPICache sharedInstance].enabled = [enabled boolValue];
        }
        
        [PubnativeLibraryCPICache request];
    } else {
        [PubnativeLibraryCPICache invokeDidFinishLoading];
    }
}

+ (PNAPIAdModel*)get
{
    PNAPIAdModel *result = [PubnativeLibraryCPICache dequeueAd];
    if ([PubnativeLibraryCPICache cacheSizeCritical]) {
        [PubnativeLibraryCPICache request];
    }
    return result;
}

#pragma mark -PRIVATE-

+ (BOOL)idle
{
    return [PubnativeLibraryCPICache sharedInstance].currentRequest == nil;
}

+ (void)invokeDidFinishLoading
{
    [PubnativeLibraryCPICache sharedInstance].currentRequest = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCPICacheDidFinishLoadingNotification object:nil];
}

+ (void)request
{
    // Avoid duplicating requests, 1 fill at a time
    if([PubnativeLibraryCPICache idle]) {
        
        PNAPIRequest *request = [[PNAPIRequest alloc] init];
        for (NSString *key in [PubnativeLibraryCPICache sharedInstance].requestParameters.allKeys) {
            NSString *value = [PubnativeLibraryCPICache sharedInstance].requestParameters[key];
            [request addParameterWithKey:key value:value];
        }
        [PubnativeLibraryCPICache sharedInstance].currentRequest = request;
        [[PubnativeLibraryCPICache sharedInstance].currentRequest startWithDelegate:[PubnativeLibraryCPICache sharedInstance]];
    }
}

#pragma mark -CACHE QUEUE-

+ (BOOL)cacheSizeCritical
{
    BOOL result = NO;
    if ([PubnativeLibraryCPICache sharedInstance].cacheQueue == nil) {
        result = YES;
    } else {
        result = [PubnativeLibraryCPICache sharedInstance].cacheQueue.count <= [PubnativeLibraryCPICache sharedInstance].cacheMinSize;
    }
    return result;
}

+ (void)enqueueAds:(NSArray*)ads
{
    NSMutableArray *newCache = [[PubnativeLibraryCPICache sharedInstance].cacheQueue mutableCopy];
    if(newCache == nil) {
        newCache = [NSMutableArray array];
    }
    for (PNAPIAdModel *ad in ads) {
        [ad setClickCaching:YES];
        [ad fetch];
        [newCache addObject:[[PubnativeLibraryCPICacheItem alloc] initWithAd:ad]];
    }
    [PubnativeLibraryCPICache sharedInstance].cacheQueue = newCache;
}

+ (PNAPIAdModel*)dequeueAd
{
    PNAPIAdModel *result = nil;
    if ([PubnativeLibraryCPICache sharedInstance].cacheQueue != nil && [PubnativeLibraryCPICache sharedInstance].cacheQueue.count > 0){
        
        // Dequeue
        PubnativeLibraryCPICacheItem *item = [PubnativeLibraryCPICache sharedInstance].cacheQueue[0];
        [[PubnativeLibraryCPICache sharedInstance].cacheQueue removeObjectAtIndex:0];
        
        // Check validty
        NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
        if (currentTimestamp > item.timestamp + [PubnativeLibraryCPICache sharedInstance].cacheThreshold) {
            result = [PubnativeLibraryCPICache dequeueAd];
        } else {
            result = item.ad;
        }
    }
    return result;
}

#pragma mark -CALLBACK-
#pragma mark PNAPIRequestDelegate

- (void)requestDidStart:(PNAPIRequest *)request
{
  // Do nothing
}

- (void)request:(PNAPIRequest *)request didLoad:(NSArray<PNAPIAdModel *> *)ads
{
    [PubnativeLibraryCPICache enqueueAds:ads];
    [PubnativeLibraryCPICache invokeDidFinishLoading];
}

- (void)request:(PNAPIRequest *)request didFail:(NSError *)error
{
    [PubnativeLibraryCPICache invokeDidFinishLoading];
}

@end
