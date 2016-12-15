//
//  PubnativeConfigModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeJSONModel.h"
#import "PubnativeNetworkModel.h"
#import "PubnativePlacementModel.h"

extern NSString * const CONFIG_GLOBAL_KEY_REFRESH;
extern NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT;
extern NSString * const CONFIG_GLOBAL_KEY_CONFIG_URL;
extern NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_BEACON;
extern NSString * const CONFIG_GLOBAL_KEY_CLICK_BEACON;
extern NSString * const CONFIG_GLOBAL_KEY_REQUEST_BEACON;

@interface PubnativeConfigModel : PubnativeJSONModel

@property (nonatomic, strong) NSDictionary<NSString*, NSObject*>                  *globals;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *request_params;
@property (nonatomic, strong) NSDictionary<NSString*, PubnativeNetworkModel*>     *networks;
@property (nonatomic, strong) NSDictionary<NSString*, PubnativePlacementModel*>   *placements;

- (BOOL)isEmpty;

- (NSObject*)globalWithKey:(NSString*)key;
- (PubnativePlacementModel*)placementWithName:(NSString*)name;
- (PubnativeNetworkModel*)networkWithID:(NSString*)networkID;
- (PubnativePriorityRuleModel*)priorityRuleWithPlacementName:(NSString*)name andIndex:(NSInteger)index;

@end
