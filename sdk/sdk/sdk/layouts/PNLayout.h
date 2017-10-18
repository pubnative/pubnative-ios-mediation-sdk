//
//  PNLayout.h
//  sdk
//
//  Created by Can Soykarafakili on 09.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLayout.h"

@class PNLayout;

@protocol PNLayoutLoadDelegate <NSObject>

- (void)layoutDidFinishLoading:(PNLayout *)layout;
- (void)layout:(PNLayout *)layout didFailLoading:(NSError *)error;

@end

@protocol PNLayoutTrackDelegate <NSObject>

- (void)layoutTrackImpression:(PNLayout *)layout;
- (void)layoutTrackClick:(PNLayout *)layout;

@end

@interface PNLayout : NSObject

@property (nonatomic, weak) NSObject<PNLayoutTrackDelegate> *trackDelegate;

- (void)loadWithAppToken:(NSString *)appToken
               placement:(NSString *)placement
                delegate:(NSObject<PNLayoutLoadDelegate>*)delegate;


@end
