//
//  PNLargeLayout.h
//  sdk
//
//  Created by Can Soykarafakili on 04.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayout+Internal.h"

@protocol PNLayoutViewDelegate <NSObject>

- (void)layoutDidShow:(PNLayout *)layout;
- (void)layoutDidHide:(PNLayout *)layout;

@end

@interface PNLargeLayout : PNLayout

@property (nonatomic, strong) NSObject<PNLayoutViewDelegate> *viewDelegate;

- (void)show;
- (void)hide;

@end
