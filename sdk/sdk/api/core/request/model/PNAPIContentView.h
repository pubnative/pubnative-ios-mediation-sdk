//
//  PNAPIContentView.h
//  library
//
//  Created by David Martin on 26/10/2016.
//  Copyright © 2016 PubNative. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kPNAPIContentViewSizeChanged;

@interface PNAPIContentView : UIView

@property (nonatomic, strong)NSString *text;
@property (nonatomic, strong)NSString *link;
@property (nonatomic, strong)NSString *icon;

@end
