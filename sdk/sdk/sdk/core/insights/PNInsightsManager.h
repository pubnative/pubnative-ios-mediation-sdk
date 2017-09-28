//
//  PNInsightsManager.h
//  sdk
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "PNInsightApiResponseModel.h"
#import "PNInsightDataModel.h"

@interface PNInsightsManager : NSObject

+ (void)trackDataWithUrl:(NSString*)url
              parameters:(NSDictionary<NSString*, NSString*>*)parameters
                    data:(PNInsightDataModel*)data;

@end
