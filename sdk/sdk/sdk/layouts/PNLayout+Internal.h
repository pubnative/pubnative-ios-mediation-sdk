//
//  PNLayout+Internal.h
//  sdk
//
//  Created by Can Soykarafakili on 20.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLayout.h"
#import "PNLayoutAdapterFactory.h"

@interface PNLayout (Internal)

@property (nonatomic, readonly) PNLayoutAdapterFactory *factory;
@property (nonatomic, strong) PNLayoutAdapter *adapter;

@end
