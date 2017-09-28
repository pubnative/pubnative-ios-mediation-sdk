//
//  PNAdModel+Fetching.h
//  sdk
//
//  Created by David Martin on 28/07/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAdModel.h"

@protocol PNAdModelFetchDelegate <NSObject>

- (void)pubnativeAdFetchDidFinish:(PNAdModel *)model;
- (void)pubnativeAdFetchDidFail:(PNAdModel *)model withError:(NSError *)error;

@end

@interface PNAdModel (Fetching)

- (void)fetchAssetsWithDelegate:(NSObject<PNAdModelFetchDelegate>*)delegate;

@end
