//
//  PNConfigManagerTest.m
//  sdk
//
//  Created by David Martin on 23/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNResourceUtils.h"
#import "PNConfigManager.h"

extern NSString * const kPNConfigKey;
extern NSString * const kPNAppTokenKey;
extern NSString * const kPNTimestampKey;

@interface PNConfigManager (Test)

+ (PNConfigManager*)sharedInstance;
- (void)setStoredAppToken:(NSString*)appToken;
- (NSString*)storedAppToken;
- (void)setStoredConfig:(PNConfigModel*)model;
- (PNConfigModel*)storedConfig;
- (void)setStoredTimestamp:(NSTimeInterval)timestamp;
- (NSTimeInterval)storedTimestamp;
- (void)updateStoredConfig:(PNConfigModel *)newConfig withAppToken:(NSString *)appToken;

+ (void)clean;

@end

@interface PNConfigManagerTest : XCTestCase

@end

@implementation PNConfigManagerTest

- (void)setUp {
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [PNConfigManager reset];
}

- (void)tearDown {
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_configWithAppToken_withEmptyAppToken_shouldReturnNil {
    
    NSObject<PNConfigManagerDelegate> *delegate = mockProtocol(@protocol(PNConfigManagerDelegate));
    [PNConfigManager configWithAppToken:@"" extras:nil delegate:delegate];
    [verify(delegate) configDidFinishWithModel:nilValue()];
}

- (void)test_configWithAppToken_withNilAppToken_shouldReturnNil {
    
    NSObject<PNConfigManagerDelegate> *delegate = mockProtocol(@protocol(PNConfigManagerDelegate));
    [PNConfigManager configWithAppToken:nil extras:nil delegate:delegate];
    [verify(delegate) configDidFinishWithModel:nilValue()];
}

- (void)test_configWithAppToken_withNilDelegateAndvalidAppToken_shouldPass {
    
    [PNConfigManager configWithAppToken:@"apptoken" extras:nil delegate:nil];
}

- (void)test_setStoredTimestamp_withPositiveValue_shouldSetValue {
    
    [[PNConfigManager sharedInstance] setStoredTimestamp:1];
    assertThatDouble([[PNConfigManager sharedInstance] storedTimestamp], equalToDouble(1));
}

- (void)test_setStoredConfig_withNilValue_shouldPass {
    
    [[PNConfigManager sharedInstance] setStoredConfig:nil];
}

- (void)test_setStoredConfig_withNilValue_shouldClearStoredValue {
    
    PNConfigModel *valid = [[PNConfigModel alloc] initWithDictionary:[PNResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    [[PNConfigManager sharedInstance] setStoredConfig:valid];
    [[PNConfigManager sharedInstance] setStoredConfig:nil];
    assertThat([[PNConfigManager sharedInstance] storedConfig], nilValue());
}

- (void)test_setStoredConfig_withEmptyValue_shouldClearStoredValue {
    
    PNConfigModel *valid = [[PNConfigModel alloc] initWithDictionary:[PNResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    [[PNConfigManager sharedInstance] setStoredConfig:valid];
    PNConfigModel *empty = [[PNConfigModel alloc] initWithDictionary:[PNResourceUtils getDictionaryFromJSONFile:@"config_empty"]];
    [[PNConfigManager sharedInstance] setStoredConfig:empty];
    assertThat([[PNConfigManager sharedInstance] storedConfig], nilValue());
}

- (void)test_setStoredConfig_withValidValue_shouldStoreValue {
    
    PNConfigModel *valid = [[PNConfigModel alloc] initWithDictionary:[PNResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    [PNConfigManager sharedInstance].storedConfig = valid;
    assertThat([PNConfigManager sharedInstance].storedConfig, notNilValue());
}

- (void)test_setStoredAppToken_withNilValue_shouldPass {
 
    [[PNConfigManager sharedInstance] setStoredAppToken:nil];
}

- (void)test_setStoredAppToken_withNilValue_shouldClearStoredValue {
    
    [[PNConfigManager sharedInstance] setStoredAppToken:@"apptoken"];
    [[PNConfigManager sharedInstance] setStoredAppToken:nil];
    assertThat([[PNConfigManager sharedInstance] storedAppToken], nilValue());
}

- (void)test_setStoredAppToken_withEmptyValue_shouldClearStoredValue {
    
    [[PNConfigManager sharedInstance] setStoredAppToken:@"apptoken"];
    [[PNConfigManager sharedInstance] setStoredAppToken:@""];
    assertThat([[PNConfigManager sharedInstance] storedAppToken], nilValue());
}

- (void)test_setStoredAppToken_withValidValue_shouldStoreSameValue {
    
    NSString *apptoken = @"appToken";
    [[PNConfigManager sharedInstance] setStoredAppToken:apptoken];
    assertThat([[PNConfigManager sharedInstance] storedAppToken], equalTo(apptoken));
}

- (void)test_updateStoredConfig_withNilAppToken_andWithValidModel_shouldPass {
    PNConfigModel *valid = [[PNConfigModel alloc] initWithDictionary:[PNResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    PNConfigManager *manager = [[PNConfigManager alloc]init];
    [manager updateStoredConfig:valid withAppToken:nil];
}

- (void)test_updateStoredConfig_withValidAppToken_andWithValidModel_shouldPass {
    PNConfigModel *valid = [[PNConfigModel alloc] initWithDictionary:[PNResourceUtils getDictionaryFromJSONFile:@"config_valid"]];
    PNConfigManager *manager = [[PNConfigManager alloc]init];
    [manager updateStoredConfig:valid withAppToken:@"appToken"];
}

@end
