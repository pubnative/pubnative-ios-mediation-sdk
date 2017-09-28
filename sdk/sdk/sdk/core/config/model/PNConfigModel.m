//
//  PNConfigModel.m
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNConfigModel.h"

NSString * const PN_CONFIG_GLOBAL_KEY_REFRESH            = @"refresh";
NSString * const PN_CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT = @"impression_timeout";
NSString * const PN_CONFIG_GLOBAL_KEY_CONFIG_URL         = @"config_url";
NSString * const PN_CONFIG_GLOBAL_KEY_IMPRESSION_BEACON  = @"impression_beacon";
NSString * const PN_CONFIG_GLOBAL_KEY_CLICK_BEACON       = @"click_beacon";
NSString * const PN_CONFIG_GLOBAL_KEY_REQUEST_BEACON     = @"request_beacon";
NSString * const PN_CONFIG_GLOBAL_KEY_CPI_CACHE_MIN_SIZE = @"ad_cache_min_size";
NSString * const PN_CONFIG_GLOBAL_KEY_CPI_CACHE_REFRESH  = @"refresh_ad_cache";
NSString * const PN_CONFIG_GLOBAL_KEY_CPI_CACHE_ENABLED  = @"cpa_cache";

@implementation PNConfigModel

- (void)dealloc
{
    self.globals = nil;
    self.request_params = nil;
    self.ad_cache_params = nil;
    self.networks = nil;
    self.placements = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.globals = dictionary[@"globals"];
        self.request_params = dictionary[@"request_params"];
        self.ad_cache_params = dictionary[@"ad_cache_params"];
        self.networks = [PNNetworkModel parseDictionaryValues:dictionary[@"networks"]];
        self.placements = [PNPlacementModel parseDictionaryValues:dictionary[@"placements"]];
    }
    return self;
}

- (BOOL)isEmpty
{
    BOOL result = YES;
    if(self.networks && [self.networks count] > 0 &&
       self.placements && [self.placements count] > 0)
    {
        result = NO;
    }
    return result;
}

- (NSObject*)globalWithKey:(NSString*)key
{
    return self.globals[key];
}

- (PNPlacementModel*)placementWithName:(NSString*)name
{
    return self.placements[name];
}

- (PNNetworkModel*)networkWithID:(NSString*)networkID
{
    return self.networks[networkID];
}
- (PNPriorityRuleModel*)priorityRuleWithPlacementName:(NSString*)name andIndex:(NSInteger)index
{
    PNPriorityRuleModel *result = nil;
    PNPlacementModel *placement = [self placementWithName:name];
    if(placement){
        result = [placement priorityRuleWithIndex:index];
    }
    return result;
}

@end
