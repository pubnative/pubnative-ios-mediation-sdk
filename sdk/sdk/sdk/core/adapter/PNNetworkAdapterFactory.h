//
//  PubnativeAdapterFactory.h
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNNetworkModel.h"
#import "PNNetworkAdapter.h"

@interface PNNetworkAdapterFactory : NSObject

+ (PNNetworkAdapter *)createApdaterWithAdapterName:(NSString*)adapterName;

@end
