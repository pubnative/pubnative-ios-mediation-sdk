//
//  PNAPIAssetGroupFactory.h
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAPIAssetGroup.h"

@interface PNAPIAssetGroupFactory : NSObject

+ (PNAPIAssetGroup*)createWithAssetGroupID:(NSNumber*)assetGroupID;

@end
