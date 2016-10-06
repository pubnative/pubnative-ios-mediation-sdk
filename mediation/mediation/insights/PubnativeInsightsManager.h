//
//  PubnativeInsightsManager.h
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "PubnativeInsightApiResponseModel.h"
#import "PubnativeInsightDataModel.h"

@interface PubnativeInsightsManager : NSObject

+ (void)trackDataWithUrl:(NSString*)url
              parameters:(NSDictionary<NSString*, NSString*>*)parameters
                    data:(PubnativeInsightDataModel*)data;

@end
