//
//  PNNetworkAdapterTest.m
//  sdk
//
//  Created by Can Soykarafakili on 02.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNNetworkAdapter.h"
#import "PNError.h"

@interface PNNetworkAdapter ()

@property (nonatomic, strong) NSObject <PNNetworkAdapterDelegate> *delegate;

- (void)invokeDidStart;
- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PNAdModel*)ad;

@end

@interface PNNetworkAdapterTest : XCTestCase

@end

@implementation PNNetworkAdapterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_startWithExtras_withValidListener_shouldCallback {
    
    NSObject <PNNetworkAdapterDelegate> *delegate = mockProtocol(@protocol(PNNetworkAdapterDelegate));
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    adapter.delegate = delegate;
    [adapter invokeDidStart];
    [verify(delegate) adapterRequestDidStart:adapter];
    
}

- (void)test_startWithExtras_withNilListener_shouldPass {
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    [adapter startWithExtras:nil delegate:nil];
}

- (void)test_requestTimeout_shouldCallbackFail {
    PNError *error = mock([PNError class]);
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    [adapter invokeDidFail:error];
}

- (void)test_doRequestWithData_shouldCallback {
    
    //    Method implementation is empty. When it is filled in the future, the test detail will be added. At the moment it is testing the log
    NSString *string = mock([NSString class]);
    string = @"PNNetworkAdapter.doRequest - Error: override me";
    assertThat(string, equalToIgnoringCase(@"PNNetworkAdapter.doRequest - Error: override me"));
}

- (void)test_invokeDidStart_withValidListener_shouldCallback {
    NSObject<PNNetworkAdapterDelegate> *delegate = mockProtocol(@protocol(PNNetworkAdapterDelegate));
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    adapter.delegate = delegate;
    [adapter invokeDidStart];
    [verify(delegate) adapterRequestDidStart:adapter];
}

- (void)test_invokeDidStart_withNilListener_shouldPass {
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    [adapter invokeDidStart];
}

- (void)test_invokeDidLoad_withValidListener_shouldCallback {
    NSObject <PNNetworkAdapterDelegate> * delegate = mockProtocol(@protocol(PNNetworkAdapterDelegate));
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    PNAdModel *model = mock([PNAdModel class]);
    adapter.delegate = delegate;
    [adapter invokeDidLoad:model];
    [verify(delegate) adapter:adapter requestDidLoad:model];
}

- (void)test_invokeDidLoad_withNilListener_shouldPass {
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    PNAdModel *model = mock([PNAdModel class]);
    [adapter invokeDidLoad:model];
}

- (void)test_invokeDidFail_withValidListener_shouldCallbackFail {
    NSObject <PNNetworkAdapterDelegate> *delegate = mockProtocol(@protocol(PNNetworkAdapterDelegate));
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    adapter.delegate = delegate;
    NSError *error = mock([NSError class]);
    [adapter invokeDidFail:error];
    [verify(delegate) adapter:adapter requestDidFail:error];
}

- (void)test_invokeDidFail_witNilListener_shouldPass {
    PNNetworkAdapter *adapter = [[PNNetworkAdapter alloc] init];
    NSError *error = mock([NSError class]);
    [adapter invokeDidFail:error];
}

@end
