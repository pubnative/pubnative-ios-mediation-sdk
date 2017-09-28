//
//  PNNetworkAdapter.h
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAdModel.h"
#import "PNNetworkModel.h"

@class PNNetworkAdapter;

@protocol PNNetworkAdapterDelegate <NSObject>

- (void)adapterRequestDidStart:(PNNetworkAdapter*)adapter;
- (void)adapter:(PNNetworkAdapter*)adapter requestDidLoad:(PNAdModel*)ad;
- (void)adapter:(PNNetworkAdapter*)adapter requestDidFail:(NSError*)error;

@end

@interface PNNetworkAdapter : NSObject

@property (nonatomic, strong)PNNetworkModel      *networkConfig;

- (void)startWithExtras:(NSDictionary<NSString *,NSString *> *)extras
               delegate:(NSObject<PNNetworkAdapterDelegate> *)delegate;

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras;

@end
