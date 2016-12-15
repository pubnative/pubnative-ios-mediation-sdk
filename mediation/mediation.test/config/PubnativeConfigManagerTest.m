//
//  PubnativeConfigManagerTest.m
//  mediation
//
//  Created by David Martin on 23/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PubnativeResourceUtils.h"
#import "PubnativeConfigManager.h"

extern NSString * const kUserDefaultsStoredConfigKey;
extern NSString * const kUserDefaultsStoredAppTokenKey;
extern NSString * const kUserDefaultsStoredTimestampKey;

@interface PubnativeConfigManager (Test)

+ (void)setStoredAppToken:(NSString*)appToken;
+ (NSString*)getStoredAppToken;
+ (void)setStoredConfig:(PubnativeConfigModel*)model;
+ (PubnativeConfigModel*)getStoredConfig;
+ (void)setStoredTimestamp:(NSTimeInterval)timestamp;
+ (NSTimeInterval)getStoredTimestamp;

+ (void)clean;

@end

@interface PubnativeConfigManagerTest : XCTestCase

@end

@implementation PubnativeConfigManagerTest

- (void)setUp {
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [PubnativeConfigManager reset];
}

- (void)tearDown {
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_configWithAppToken_withEmptyAppToken_shouldReturnNil {
    
    NSObject<PubnativeConfigManagerDelegate> *delegate = mockProtocol(@protocol(PubnativeConfigManagerDelegate));
    [PubnativeConfigManager configWithAppToken:@"" extras:nil delegate:delegate];
    [verify(delegate) configDidFinishWithModel:nilValue()];
}

- (void)test_configWithAppToken_withNilAppToken_shouldReturnNil {
    
    NSObject<PubnativeConfigManagerDelegate> *delegate = mockProtocol(@protocol(PubnativeConfigManagerDelegate));
    [PubnativeConfigManager configWithAppToken:nil extras:nil delegate:delegate];
    [verify(delegate) configDidFinishWithModel:nilValue()];
}

- (void)test_configWithAppToken_withNilDelegateAndvalidAppToken_shouldPass {
    
    [PubnativeConfigManager configWithAppToken:@"apptoken" extras:nil delegate:nil];
}

- (void)test_setStoredTimestamp_withNegativeValue_shouldClearValue {
    
    [PubnativeConfigManager setStoredTimestamp:1];
    [PubnativeConfigManager setStoredTimestamp:-1];
    assertThatDouble([PubnativeConfigManager getStoredTimestamp], equalToDouble(0));
}

- (void)test_setStoredTimestamp_withZeroValue_shouldClearValue {
    
    [PubnativeConfigManager setStoredTimestamp:1];
    [PubnativeConfigManager setStoredTimestamp:0];
    assertThatDouble([PubnativeConfigManager getStoredTimestamp], equalToDouble(0));
}

- (void)test_setStoredTimestamp_withPositiveValue_shouldSetValue {
    
    [PubnativeConfigManager setStoredTimestamp:1];
    assertThatDouble([PubnativeConfigManager getStoredTimestamp], equalToDouble(1));
}

- (void)test_setStoredConfig_withNilValue_shouldPass {
    
    [PubnativeConfigManager setStoredConfig:nil];
}

- (void)test_setStoredConfig_withNilValue_shouldClearStoredValue {
    
    PubnativeConfigModel *valid = [[PubnativeConfigModel alloc] initWithDictionary:[PubnativeResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    [PubnativeConfigManager setStoredConfig:valid];
    [PubnativeConfigManager setStoredConfig:nil];
    assertThat([PubnativeConfigManager getStoredConfig], nilValue());
}

- (void)test_setStoredConfig_withEmptyValue_shouldClearStoredValue {
    
    PubnativeConfigModel *valid = [[PubnativeConfigModel alloc] initWithDictionary:[PubnativeResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    [PubnativeConfigManager setStoredConfig:valid];
    PubnativeConfigModel *empty = [[PubnativeConfigModel alloc] initWithDictionary:[PubnativeResourceUtils getDictionaryFromJSONFile:@"config_empty"]];
    [PubnativeConfigManager setStoredConfig:empty];
    assertThat([PubnativeConfigManager getStoredConfig], nilValue());
}

- (void)test_setStoredConfig_withValidValue_shouldStoreValue {
    
    PubnativeConfigModel *valid = [[PubnativeConfigModel alloc] initWithDictionary:[PubnativeResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    [PubnativeConfigManager setStoredConfig:valid];
    assertThat([PubnativeConfigManager getStoredConfig], notNilValue());
}

- (void)test_setStoredAppToken_withNilValue_shouldPass {
 
    [PubnativeConfigManager setStoredAppToken:nil];
}

- (void)test_setStoredAppToken_withNilValue_shouldClearStoredValue {
    
    [PubnativeConfigManager setStoredAppToken:@"apptoken"];
    [PubnativeConfigManager setStoredAppToken:nil];
    assertThat([PubnativeConfigManager getStoredAppToken], nilValue());
}

- (void)test_setStoredAppToken_withEmptyValue_shouldClearStoredValue {
    
    [PubnativeConfigManager setStoredAppToken:@"apptoken"];
    [PubnativeConfigManager setStoredAppToken:@""];
    assertThat([PubnativeConfigManager getStoredAppToken], nilValue());
}

- (void)test_setStoredAppToken_withValidValue_shouldStoreSameValue {
    
    NSString *apptoken = @"appToken";
    [PubnativeConfigManager setStoredAppToken:apptoken];
    assertThat([PubnativeConfigManager getStoredAppToken], equalTo(apptoken));
}

@end
