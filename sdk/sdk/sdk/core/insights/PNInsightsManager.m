//
//  PNInsightsManager.m
//  sdk
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PNInsightsManager.h"
#import "PNInsightRequestModel.h"
#import "PNInsightApiResponseModel.h"
#import "PNHttpRequest.h"
#import "PNConfigManager.h"

NSString * const kPNInsightsManagerQueueKey          = @"PNInsightsManager.queue.key";
NSString * const kPNInsightsManagerFailedQueueKey    = @"PNInsightsManager.failedQueue.key";

@interface PNInsightsManager () <NSURLConnectionDataDelegate>

@property (nonatomic, assign)BOOL idle;

@end

@implementation PNInsightsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idle = YES;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static PNInsightsManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PNInsightsManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)trackDataWithUrl:(NSString*)url
              parameters:(NSDictionary<NSString*,NSString*>*)parameters
                    data:(PNInsightDataModel*)data
{
    if (data && url && url.length > 0) {
        
        PNInsightRequestModel *model = [[PNInsightRequestModel alloc] init];
        model.data.generated_at = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970]*1000000)];
        model.data = data;
        model.params = parameters;
        model.url = url;
        
        NSMutableArray *failedQueue = [PNInsightsManager queueForKey:kPNInsightsManagerFailedQueueKey];
        for (NSDictionary *failedItemDictionary in failedQueue) {
            
            PNInsightRequestModel *failedItem = [[PNInsightRequestModel alloc] initWithDictionary:failedItemDictionary];
            [PNInsightsManager enqueueRequestModel:failedItem];
        }
        [PNInsightsManager setQueue:nil forKey:kPNInsightsManagerFailedQueueKey];
        
        [PNInsightsManager enqueueRequestModel:model];
        [PNInsightsManager doNextRequest];

    } else {
        NSLog(@"PNInsightsManager - data or url to track are nil");
    }
}

+ (void)doNextRequest
{
    if([PNInsightsManager sharedInstance].idle){
        [PNInsightsManager sharedInstance].idle = NO;
        PNInsightRequestModel *model = [PNInsightsManager dequeueRequestModel];
        if(model){
            [PNInsightsManager sendRequest:model];
        } else {
            [PNInsightsManager sharedInstance].idle = YES;
        }
    }
}

+ (void)sendRequest:(PNInsightRequestModel *) model
{
    NSString *url = [PNInsightsManager requestUrlWithModel:model];
    NSError *error = nil;
    NSDictionary *modelDictionary = [model.data toDictionary];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelDictionary
                                                   options:0
                                                     error:&error];
    if (error) {
        NSLog(@"PubnativeInsightsManager - request model parsing error: %@", error);
        [PNInsightsManager sharedInstance].idle = YES;
        [PNInsightsManager doNextRequest];
    } else {
        __block PNInsightRequestModel *requestModelBlock = model;
        [PNHttpRequest requestWithURL:url
                                    httpBody:jsonData
                                     timeout:60
                        andCompletionHandler:^(NSString *result, NSError *error) {
                            
            if (error) {
                NSLog(@"PNInsightsManager - request error: %@", error.localizedDescription);
                [PNInsightsManager enqueueFailedRequestModel:requestModelBlock
                                                          withError:error.localizedDescription];
            } else {
                NSData *jsonResponse = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSError *parseError;
                NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:jsonResponse
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:&parseError];
                if(parseError){
                    NSLog(@"PNInsightsManager - tracking response parsing error: %@", result);
                } else {
                    PNInsightApiResponseModel *apiResponse = [PNInsightApiResponseModel modelWithDictionary:jsonDictonary];
                    if([apiResponse isSuccess]) {
                        NSLog(@"PNInsightsManager - tracking %@ success: %@", url, result);
                    } else {
                        NSLog(@"PNInsightsManager - tracking failed: %@", apiResponse.error_message);
                        [PNInsightsManager enqueueFailedRequestModel:requestModelBlock
                                                                  withError:apiResponse.error_message];
                    }
                }
            }
            [PNInsightsManager sharedInstance].idle = YES;
            [PNInsightsManager doNextRequest];
        }];
    }
}

+ (NSString*)requestUrlWithModel:(PNInsightRequestModel*)model
{
    NSString *result = nil;
    if (model && model.url && model.url.length > 0) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:model.url];
        if (components) {
            if (model.params){
                NSMutableArray *queryItems = [NSMutableArray array];
                for (NSString *key in model.params) {
                    if(key && key.length > 0){
                        NSString *value = model.params[key];
                        if(value && value.length > 0) {
                            NSString *queryItem = [NSString stringWithFormat:@"%@=%@",key,value];
                            [queryItems addObject:queryItem];
                        }
                    }
                }
                NSString *componentsString = [queryItems componentsJoinedByString:@"&"];
                [components setQuery:[componentsString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
            }
        }
        result = [components.URL absoluteString];
    }
    return result;
}

#pragma mark - QUEUE -

+ (void)enqueueRequestModel:(PNInsightRequestModel *)request
{
    if(request){
        NSMutableArray *queue = [PNInsightsManager queueForKey:kPNInsightsManagerQueueKey];
        [queue addObject:[request toDictionary]];
        [PNInsightsManager setQueue:queue forKey:kPNInsightsManagerQueueKey];
    }
}

+ (PNInsightRequestModel*)dequeueRequestModel
{
    PNInsightRequestModel *result = nil;
    NSMutableArray *queue = [PNInsightsManager queueForKey:kPNInsightsManagerQueueKey];
    if (queue.count > 0) {
        result = [[PNInsightRequestModel alloc] initWithDictionary:queue[0]];
        [queue removeObjectAtIndex:0];
        [PNInsightsManager setQueue:queue forKey:kPNInsightsManagerQueueKey];
    }
    return result;
}

+ (void)enqueueFailedRequestModel:(PNInsightRequestModel *)request
                        withError:(NSString*)error
{
    if(request){
        request.data.retry = [NSNumber numberWithInteger:[request.data.retry integerValue] + 1];
        request.data.retry_error = error;
        NSMutableArray *queue = [PNInsightsManager queueForKey:kPNInsightsManagerFailedQueueKey];
        [queue addObject:[request toDictionary]];
        [PNInsightsManager setQueue:queue forKey:kPNInsightsManagerFailedQueueKey];
    }
}

#pragma mark NSUserDefaults

+ (NSMutableArray*)queueForKey:(NSString*)key
{
    NSArray *queue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSMutableArray *result;

    if(queue){
        result = [queue mutableCopy];
    } else {
        result = [NSMutableArray array];
    }
    return result;
}

+ (void)setQueue:(NSArray*)queue forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:queue
                                              forKey:key];
}

@end

