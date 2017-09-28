//
//  PNConfigModel.h
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"
#import "PNNetworkModel.h"
#import "PNPlacementModel.h"

extern NSString * const PN_CONFIG_GLOBAL_KEY_REFRESH;
extern NSString * const PN_CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT;
extern NSString * const PN_CONFIG_GLOBAL_KEY_CONFIG_URL;
extern NSString * const PN_CONFIG_GLOBAL_KEY_IMPRESSION_BEACON;
extern NSString * const PN_CONFIG_GLOBAL_KEY_CLICK_BEACON;
extern NSString * const PN_CONFIG_GLOBAL_KEY_REQUEST_BEACON;
extern NSString * const PN_CONFIG_GLOBAL_KEY_CPI_CACHE_MIN_SIZE;
extern NSString * const PN_CONFIG_GLOBAL_KEY_CPI_CACHE_REFRESH;
extern NSString * const PN_CONFIG_GLOBAL_KEY_CPI_CACHE_ENABLED;

@interface PNConfigModel : PNJSONModel

@property (nonatomic, strong) NSDictionary<NSString*, NSObject*>            *globals;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>            *request_params;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>            *ad_cache_params;
@property (nonatomic, strong) NSDictionary<NSString*, PNNetworkModel*>   *networks;
@property (nonatomic, strong) NSDictionary<NSString*, PNPlacementModel*> *placements;

@property (nonatomic, readonly) BOOL isEmpty;

- (NSObject*)globalWithKey:(NSString*)key;
- (PNPlacementModel*)placementWithName:(NSString*)name;
- (PNNetworkModel*)networkWithID:(NSString*)networkID;
- (PNPriorityRuleModel*)priorityRuleWithPlacementName:(NSString*)name andIndex:(NSInteger)index;

@end
