//
//  PNAPIDrillerTest.m
//  sdk
//
//  Created by Can Soykarafakili on 04.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "PNAPIDriller.h"

@interface PNAPIDriller ()

@property (nonatomic, strong) NSObject <PNAPIDrillerDelegate> *delegate;

- (void)invokeDidStartWithURL:(NSURL*)url;

@end

@interface PNAPIDrillerTest : XCTestCase

@end

@implementation PNAPIDrillerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_startDrillWithURLString_withNilDelegateAndvalidUrl_shouldPass {
    PNAPIDriller *driller = [[PNAPIDriller alloc] init];
    [driller startDrillWithURLString:@"validURL" delegate:nil];
}

- (void)test_startDrillWithURLString_withNilUrl_shouldPass {
    PNAPIDriller *driller = [[PNAPIDriller alloc] init];
    NSObject<PNAPIDrillerDelegate> *delegate = mockProtocol(@protocol(PNAPIDrillerDelegate));
    [driller startDrillWithURLString:nil delegate:delegate];
}

- (void)test_startDrillWithURLString_withEmptyUrl_shouldPass {
    PNAPIDriller *driller = [[PNAPIDriller alloc] init];
    NSObject<PNAPIDrillerDelegate> *delegate = mockProtocol(@protocol(PNAPIDrillerDelegate));
    [driller startDrillWithURLString:@"" delegate:delegate];
}

- (void)test_startDrillWithURLString_withValidDelegateAndvalidUrl_shouldPass {
    PNAPIDriller *driller = [[PNAPIDriller alloc] init];
    NSObject<PNAPIDrillerDelegate> *delegate = mockProtocol(@protocol(PNAPIDrillerDelegate));
    NSString *string = mock([NSString class]);
    string = @"validURL";
    driller.delegate = delegate;
    [driller invokeDidStartWithURL:[NSURL URLWithString:string]];
}
@end
