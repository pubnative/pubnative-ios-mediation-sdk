//
//  PNAPIAssetGroup.h
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPILayoutViewController.h"
#import "PNAPIAdModel.h"

extern CGFloat const kPNCTACornerRadius;

@class PNAPIAssetGroup;

@protocol PNAPIAssetGroupLoadDelegate <NSObject>

- (void)assetGroupLoadDidFinish:(PNAPIAssetGroup*)assetGroup;
- (void)assetGroup:(PNAPIAssetGroup*)assetGroup loadDidFail:(NSError*)error;

@end

@interface PNAPIAssetGroup : PNAPILayoutViewController <PNAPIAdModelDelegate>

@property (nonatomic, strong)PNAPIAdModel *model;
@property (nonatomic, strong)NSObject<PNAPIAssetGroupLoadDelegate> *loadDelegate;

- (void)invokeLoadFinish;
- (void)invokeLoadFail:(NSError*)error;
- (void)load;
- (void)updateContentInfoSize:(NSNotification *)notification;

@end
