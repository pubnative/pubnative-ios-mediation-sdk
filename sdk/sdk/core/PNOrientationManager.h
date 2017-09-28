//
//  PNOrientationManager.h
//  sdk
//
//  Created by Can Soykarafakili on 21.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kPNOrientationManagerDidChangeOrientation;

@interface PNOrientationManager : NSObject

+ (UIInterfaceOrientation)orientation;

@end
