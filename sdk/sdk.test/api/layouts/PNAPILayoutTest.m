//
//  PNAPILayoutTest.m
//  sdk
//
//  Created by Can Soykarafakili on 12.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNAPILayout.h"
#import "PNAPIAssetGroup.h"

@interface PNAPILayout()

@property(nonatomic, strong)NSObject<PNAPILayoutLoadDelegate> *loadDelegate;
@property(nonatomic, strong)NSObject<PNAPILayoutFetchDelegate> *fetchDelegate;

- (void)invokeLoadDidFinish:(PNAPIAdModel *)model;
- (void)invokeLoadDidFail:(NSError*)error;
- (void)invokeFetchDidFinish:(PNAPIAssetGroup*)assetGroup;
- (void)invokeFetchDidFail:(NSError*)error;
- (void)invokeOrientationDidFinish:(PNAPIAssetGroup*)assetGroup;
- (void)invokeOrientationDidFail:(NSError*)error;

@end

@interface PNAPILayoutTest : XCTestCase

@end

@implementation PNAPILayoutTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_loadWithSize_withNilListener_shouldPass
{
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    [apiLayout loadWithSize:SMALL loadDelegate:nil];
}

- (void)test_loadWithSize_withValidListener_shouldPass
{
    NSObject<PNAPILayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNAPILayoutLoadDelegate));
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    [apiLayout loadWithSize:SMALL loadDelegate:delegate];
}

- (void)test_fetchWithDelegate_withNilListener_shouldPass
{
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    [apiLayout fetchWithDelegate:nil];
}

- (void)test_fetchWithDelegate_withValidListener_shouldPass
{
    NSObject<PNAPILayoutFetchDelegate> *delegate = mockProtocol(@protocol(PNAPILayoutFetchDelegate));
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    [apiLayout fetchWithDelegate:delegate];
}

- (void)test_invokeLoadDidFinish_withValidListener_shouldCallback
{
    NSObject<PNAPILayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNAPILayoutLoadDelegate));
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    PNAPIAdModel *model = mock([PNAPIAdModel class]);
    apiLayout.loadDelegate = delegate;
    [apiLayout invokeLoadDidFinish:model];
    [verify(delegate)layout:apiLayout loadDidFinish:model];
}

- (void)test_invokeLoadDidFail_withValidListener_shouldCallback
{
    NSObject<PNAPILayoutLoadDelegate> *delegate = mockProtocol(@protocol(PNAPILayoutLoadDelegate));
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    NSError *error = mock([NSError class]);
    apiLayout.loadDelegate = delegate;
    [apiLayout invokeLoadDidFail:error];
    [verify(delegate)layout:apiLayout loadDidFail:error];
}

- (void)test_invokeFetchDidFinish_withValidListener_shouldCallback
{
    NSObject<PNAPILayoutFetchDelegate> *delegate = mockProtocol(@protocol(PNAPILayoutFetchDelegate));
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    PNAPIAssetGroup *assetGroup = mock([PNAPIAssetGroup class]);
    apiLayout.fetchDelegate = delegate;
    [apiLayout invokeFetchDidFinish:assetGroup];
    [verify(delegate)layout:apiLayout fetchDidFinish:assetGroup];
}

- (void)test_invokeFetchDidFail_withValidListener_shouldCallback
{
    NSObject<PNAPILayoutFetchDelegate> *delegate = mockProtocol(@protocol(PNAPILayoutFetchDelegate));
    PNAPILayout *apiLayout = [[PNAPILayout alloc] init];
    NSError *error = mock([NSError class]);
    apiLayout.fetchDelegate = delegate;
    [apiLayout invokeFetchDidFail:error];
    [verify(delegate)layout:apiLayout fetchDidFail:error];
}

@end
