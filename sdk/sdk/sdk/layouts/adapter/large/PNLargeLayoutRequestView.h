//
//  PNLargeLayoutRequestView.h
//  sdk
//
//  Created by Can Soykarafakili on 05.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pubnative/Pubnative.h>
#import "PNLargeLayout.h"
#import "PNAdModel.h"

@interface PNLargeLayoutRequestView : UIViewController

- (void)loadWithAd:(PNAdModel *)nativeAd;

@end
