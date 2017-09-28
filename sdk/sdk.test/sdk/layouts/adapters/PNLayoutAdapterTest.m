//
//  PNLayoutAdapterTest.m
//  sdk
//
//  Created by Can Soykarafakili on 12.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNLayoutAdapter.h"

@interface PNLayoutAdapter()

- (void)invokeDidFinishLoading;
- (void)invokeDidFailLoadingWithError:(NSError *)error;
- (void)invokeDidFinishFetching;
- (void)invokeDidFailFetchingWithError:(NSError *)error;
- (void)invokeClick;
- (void)invokeImpression;

@end

@interface PNLayoutAdapterTest : XCTestCase

@end

@implementation PNLayoutAdapterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_invokeDidFinishLoading_withValidListener_shouldCallback
{
    NSObject<PNLayoutAdapterLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutAdapterLoadDelegate));
    PNLayoutAdapter *layoutAdapter = [[PNLayoutAdapter alloc] init];
    layoutAdapter.loadDelegate = delegate;
    [layoutAdapter invokeDidFinishLoading];
    [verify(delegate)layoutAdapterDidFinishLoading:layoutAdapter];
}

- (void)test_invokeDidFailLoading_withValidListener_shouldCallback
{
    NSObject<PNLayoutAdapterLoadDelegate> *delegate = mockProtocol(@protocol(PNLayoutAdapterLoadDelegate));
    NSError *error = mock([NSError class]);
    PNLayoutAdapter *layoutAdapter = [[PNLayoutAdapter alloc] init];
    layoutAdapter.loadDelegate = delegate;
    [layoutAdapter invokeDidFailLoadingWithError:error];
    [verify(delegate)layoutAdapter:layoutAdapter didFailLoading:error];
}

- (void)test_invokeDidFinishFetching_withValidListener_shouldCallback
{
    NSObject<PNLayoutAdapterFetchDelegate> *delegate = mockProtocol(@protocol(PNLayoutAdapterFetchDelegate));
    PNLayoutAdapter *layoutAdapter = [[PNLayoutAdapter alloc] init];
    layoutAdapter.fetchDelegate = delegate;
    [layoutAdapter invokeDidFinishFetching];
    [verify(delegate)layoutAdapterDidFinishFetching:layoutAdapter];
}

- (void)test_invokeDidFailFetching_withValidListener_shouldCallback
{
    NSObject<PNLayoutAdapterFetchDelegate> *delegate = mockProtocol(@protocol(PNLayoutAdapterFetchDelegate));
    NSError *error = mock([NSError class]);
    PNLayoutAdapter *layoutAdapter = [[PNLayoutAdapter alloc] init];
    layoutAdapter.fetchDelegate = delegate;
    [layoutAdapter invokeDidFailFetchingWithError:error];
    [verify(delegate)layoutAdapter:layoutAdapter didFailFetching:error];
}

- (void)test_invokeClick_withValidListener_shouldCallback
{
    NSObject<PNLayoutAdapterTrackDelegate> *delegate = mockProtocol(@protocol(PNLayoutAdapterTrackDelegate));
    PNLayoutAdapter *layoutAdapter = [[PNLayoutAdapter alloc] init];
    layoutAdapter.trackDelegate = delegate;
    [layoutAdapter invokeClick];
    [verify(delegate)layoutAdapterTrackClick:layoutAdapter];
}

- (void)test_invokeImpression_withValidListener_shouldCallback
{
    NSObject<PNLayoutAdapterTrackDelegate> *delegate = mockProtocol(@protocol(PNLayoutAdapterTrackDelegate));
    PNLayoutAdapter *layoutAdapter = [[PNLayoutAdapter alloc] init];
    layoutAdapter.trackDelegate = delegate;
    [layoutAdapter invokeImpression];
    [verify(delegate)layoutAdapterTrackImpression:layoutAdapter];
}

@end
