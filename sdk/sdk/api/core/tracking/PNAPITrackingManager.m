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

#import "PNAPITrackingManager.h"
#import "PNAPITrackingManagerItem.h"
#import "PNAPIHttpRequest.h"

NSString * const kPNAPITrackingManagerQueueKey             = @"PNAPITrackingManager.queue.key";
NSString * const kPNAPITrackingManagerFailedQueueKey       = @"PNAPITrackingManager.failedQueue.key";
NSTimeInterval const kPNAPITrackingManagerItemValidTime    = 1800;

@interface PNAPITrackingManager () <PNAPIHttpRequestDelegate>

@property (nonatomic, assign)BOOL                   isRunning;
@property (nonatomic, strong)PNAPITrackingManagerItem  *currentItem;

@end

@implementation PNAPITrackingManager

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.currentItem = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isRunning = NO;
    }
    return self;
}

#pragma mark
#pragma mark PNAPITrackingManager
#pragma mark

+ (instancetype)sharedManager
{
    static PNAPITrackingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PNAPITrackingManager alloc] init];
    });
    return instance;
}

+ (void)trackWithURL:(NSURL*)url
{
    if (url == nil) {
        NSLog(@"PNAPITrackingManager - Url passed is nil or empty, dropping this call: %@", url);
    } else {
        
        // Enqueue failed items
        NSMutableArray *failedQueue = [self queueForKey:kPNAPITrackingManagerFailedQueueKey];
        for (NSDictionary *dictionary in failedQueue) {
            
            PNAPITrackingManagerItem *item = [[PNAPITrackingManagerItem alloc] initWithDictionary:dictionary];
            [self enqueueItem:item withQueueKey:kPNAPITrackingManagerFailedQueueKey];
        }
        [self setQueue:nil forKey:kPNAPITrackingManagerFailedQueueKey];
        
        // Enqueue new item
        PNAPITrackingManagerItem *item = [[PNAPITrackingManagerItem alloc] init];
        item.url = url;
        item.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [self enqueueItem:item withQueueKey:kPNAPITrackingManagerQueueKey];
        [[self sharedManager] trackNextItem];
    }
}

- (void)trackNextItem
{
    if(!self.isRunning) {
        
        self.isRunning = YES;
        PNAPITrackingManagerItem *item = [PNAPITrackingManager dequeueItemWithQueueKey:kPNAPITrackingManagerQueueKey];
        
        // If there are no items
        if(item) {
            
            self.currentItem = item;
            
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval itemTimestamp = [item.timestamp doubleValue];
            
            if((currentTimestamp - itemTimestamp) < kPNAPITrackingManagerItemValidTime) {
                // Track item
                [[PNAPIHttpRequest alloc] startWithUrlString:[self.currentItem.url absoluteString]
                                                 delegate:self];
            } else {
                // Discard the item and continue
                [self trackNextItem];
            }
        } else {
            self.isRunning = NO;
        }
    }
}

#pragma mark - QUEUE -

+ (void)enqueueItem:(PNAPITrackingManagerItem*)item withQueueKey:(NSString*)key
{
    if(item){
        NSMutableArray *queue = [PNAPITrackingManager queueForKey:key];
        [queue addObject:[item toDictionary]];
        [PNAPITrackingManager setQueue:queue forKey:key];
    }
}

+ (PNAPITrackingManagerItem*)dequeueItemWithQueueKey:(NSString*)key
{
    PNAPITrackingManagerItem *result = nil;
    NSMutableArray *queue = [PNAPITrackingManager queueForKey:key];
    if (queue.count > 0) {
        result = [[PNAPITrackingManagerItem alloc] initWithDictionary:queue[0]];
        [queue removeObjectAtIndex:0];
        [PNAPITrackingManager setQueue:queue forKey:key];
    }
    return result;
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

#pragma mark
#pragma mark CALLBACKS
#pragma mark
#pragma mark PNAPIHttpRequestDelegate

- (void)request:(PNAPIHttpRequest *)request didFailWithError:(NSError *)error
{
    [PNAPITrackingManager enqueueItem:self.currentItem withQueueKey:kPNAPITrackingManagerFailedQueueKey];
    self.isRunning = NO;
    [self trackNextItem];
}

- (void)request:(PNAPIHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode
{
    self.isRunning = NO;
    [self trackNextItem];
}

@end
