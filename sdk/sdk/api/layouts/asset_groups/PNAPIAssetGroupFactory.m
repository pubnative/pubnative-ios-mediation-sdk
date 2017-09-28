//
//  PNAPIAssetGroupFactory.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroupFactory.h"

@implementation PNAPIAssetGroupFactory

+ (PNAPIAssetGroup*)createWithAssetGroupID:(NSNumber*)assetGroupID
{
    PNAPIAssetGroup *result = nil;
    
    if (assetGroupID == nil) {
        NSLog(@"PNAPIAssetGroupFactory.createWithAssetGroupID - Invalid asset group");
    } else {
        NSString *className = NSStringFromClass([PNAPIAssetGroup class]);
        NSString *assetGroupName = [NSString stringWithFormat:@"%@%d", className, [assetGroupID intValue]];
        Class assetGroupClass = NSClassFromString(assetGroupName);
        if (assetGroupClass && [assetGroupClass isSubclassOfClass:[PNAPIAssetGroup class]]) {
            result = [[assetGroupClass alloc] init];
        } else {
            NSLog(@"PNAPIAssetGroupFactory.createWithAssetGroupID - Asset group class not found");
        }
    }
    
    return result;
}

@end
