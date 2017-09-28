//
//  PNPlacementModel.h
//  sdk
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNJSONModel.h"
#import "PNPriorityRuleModel.h"

@interface PNPlacementModel : PNJSONModel

@property(nonatomic,strong)NSString                         *ad_format_code;
@property(nonatomic,strong)NSArray<PNPriorityRuleModel*> *priority_rules;

- (PNPriorityRuleModel*)priorityRuleWithIndex:(NSInteger)index;

@end
