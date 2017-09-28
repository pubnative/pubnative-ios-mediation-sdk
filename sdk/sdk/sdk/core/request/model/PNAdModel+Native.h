//
//  PNAdModel+Native.h
//  sdk
//
//  Created by Can Soykarafakili on 31.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAdModel.h"

@interface PNAdModel (Native)

@property (readonly)NSString *iconURLString;
@property (readonly)NSString *bannerURLString;

- (void)invokeDidConfirmImpression;
- (void)invokeDidClick;

@end
