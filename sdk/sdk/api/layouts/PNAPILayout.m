
#import "PNAPILayout.h"
#import "PNAPIRequestParameter.h"
#import "PNAPIAssetGroup.h"
#import "PNAPIAssetGroupOriented.h"
#import "PNAPIAssetGroupFactory.h"

@interface PNAPILayout () <PNAPIRequestDelegate, PNAPIAssetGroupLoadDelegate>

@property(nonatomic, assign)PNAPILayoutSize size;
@property(nonatomic, strong)NSObject<PNAPILayoutLoadDelegate> *loadDelegate;
@property(nonatomic, strong)NSObject<PNAPILayoutFetchDelegate> *fetchDelegate;

@end

@implementation PNAPILayout

#pragma mark NSObject

- (void)dealloc
{
    self.loadDelegate = nil;
    self.fetchDelegate = nil;
    self.model = nil;
}

#pragma mark PNAPILayout

- (void)loadWithSize:(PNAPILayoutSize)size loadDelegate:(NSObject<PNAPILayoutLoadDelegate>*)loadDelegate
{
    if (loadDelegate == nil) {
        NSLog(@"PNAPILayout.loadWithSize - Error: load delegate is nil and required");
    } else {
        self.size = size;
        self.loadDelegate = loadDelegate;
        NSString *sizeString = [self stringWithSize:size];
        [self addParameterWithKey:[PNAPIRequestParameter assetLayout] value:sizeString];
        [self startWithDelegate:self];
    }
}

- (NSString*)stringWithSize:(PNAPILayoutSize)size
{
    NSString *result = nil;
    switch (size) {
        case SMALL: result = @"s"; break;
        case MEDIUM: result = @"m"; break;
        case LARGE: result = @"l"; break;
    }
    return result;
}

- (void)fetchWithDelegate:(NSObject<PNAPILayoutFetchDelegate>*)fetchDelegate
{
    if (fetchDelegate == nil) {
        NSLog(@"PNAPILayout.fetchWithDelegate - Error: fetch delegate is nil and required");
    } else if(self.model == nil) {
        NSLog(@"PNAPILayout.fetchWithDelegate - Error: layout not loaded, please load before fetch");
    } else {
        self.fetchDelegate = fetchDelegate;
        PNAPIAssetGroup *assetGroup = [PNAPIAssetGroupFactory createWithAssetGroupID:self.model.assetGroupID];
        if(assetGroup == nil) {
            [self invokeFetchDidFail:[NSError errorWithDomain:@"PNAPILayout.fetchWithDelegate - Error: layout cannot be load"
                                                         code:0
                                                     userInfo:nil]];
        } else {
            assetGroup.loadDelegate = self;
            assetGroup.model = self.model;
            [assetGroup load];
        }
    }
}

- (void)invokeLoadDidFinish:(PNAPIAdModel *)model
{
    NSObject<PNAPILayoutLoadDelegate> *delegate = self.loadDelegate;
    self.loadDelegate = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(layout:loadDidFinish:)]) {
        [delegate layout:self loadDidFinish:model];
    }
}

- (void)invokeLoadDidFail:(NSError*)error
{
    NSObject<PNAPILayoutLoadDelegate> *delegate = self.loadDelegate;
    self.loadDelegate = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(layout:loadDidFail:)]) {
        [delegate layout:self loadDidFail:error];
    }
}

- (void)invokeFetchDidFinish:(PNAPIAssetGroup*)assetGroup
{
    NSObject<PNAPILayoutFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(layout:fetchDidFinish:)]) {
        [delegate layout:self fetchDidFinish:assetGroup];
    }
}

- (void)invokeFetchDidFail:(NSError*)error
{
    NSObject<PNAPILayoutFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(layout:fetchDidFail:)]) {
        [delegate layout:self fetchDidFail:error];
    }
}

#pragma mark - Callbacks -

#pragma mark PNAPIRequest

- (void)requestDidStart:(PNAPIRequest*)request
{
    // Do nothing
}

- (void)request:(PNAPIRequest*)request didLoad:(NSArray<PNAPIAdModel*>*)ads
{
    if(ads == nil || [ads count] == 0) {
        NSError *noFillError = [NSError errorWithDomain:@"PNAPILayout - Error: NO FILL"
                                                   code:0
                                               userInfo:nil];
        [self invokeLoadDidFail:noFillError];
    } else {
        self.model = ads[0];
        [self invokeLoadDidFinish:self.model];
    }
}

- (void)request:(PNAPIRequest*)request didFail:(NSError*)error
{
    [self invokeLoadDidFail:error];
}

#pragma mark PNAPIAssetGroupLoadDelegate

- (void)assetGroupLoadDidFinish:(PNAPIAssetGroup*)assetGroup
{
    [self invokeFetchDidFinish:assetGroup];
}

- (void)assetGroup:(PNAPIAssetGroup*)assetGroup loadDidFail:(NSError*)error
{
    [self invokeFetchDidFail:error];
}

@end
