//
//  PubnativeAdapterFactory.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeNetworkModel.h"
#import "PubnativeNetworkAdapter.h"

@interface PubnativeNetworkAdapterFactory : NSObject

+ (PubnativeNetworkAdapter *)createApdaterWithAdapterName:(NSString*)adapterName;

@end
