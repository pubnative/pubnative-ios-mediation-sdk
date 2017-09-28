//
//  PubnativePriorityRulesModel.h
//  sdk
//
//  Created by Mohit on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"

@interface PNPriorityRuleModel : PNJSONModel

@property (nonatomic, strong)NSNumber       *identifier;
@property (nonatomic, strong)NSString       *network_code;
@property (nonatomic, strong)NSDictionary   *params;
@property (nonatomic, strong)NSArray        *segment_ids;

@end
