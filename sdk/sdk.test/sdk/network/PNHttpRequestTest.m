//
//  PNHttpRequestTest.m
//  sdk
//
//  Created by Can Soykarafakili on 03.05.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "PNHttpRequest.h"

@interface PNHttpRequestTest : XCTestCase

@end

@implementation PNHttpRequestTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_requestWithURL_withEmptyUrl_shouldPass {
    [PNHttpRequest requestWithURL:@"" timeout:60 andCompletionHandler:^(NSString *result, NSError *error) {
    }];
}

- (void)test_requestWithURL_withNilUrl_shouldPass {
    [PNHttpRequest requestWithURL:nil timeout:60 andCompletionHandler:^(NSString *result, NSError *error) {
    }];
}

- (void)test_requestWithURL_withValidUrl_shouldPass {
    [PNHttpRequest requestWithURL:nil timeout:60 andCompletionHandler:^(NSString *result, NSError *error) {
    }];
}

@end
