//
//  PNLayoutViewController.h
//  sdk
//
//  Created by Can Soykarafakili on 26.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LEFT,
    RIGHT
}IconPosition;

@interface PNLayoutViewController : UIViewController

- (void)iconWithPosition:(IconPosition)position;
- (void)containerBackgroundColor:(UIColor *)color;
- (void)adBackgroundColor:(UIColor *)color;
- (void)titleTextColor:(UIColor *)color;
- (void)titleFontWithName:(NSString *)fontName size:(CGFloat)size;
- (void)descriptionTextColor:(UIColor *)color;
- (void)descriptionFontWithName:(NSString *)fontName size:(CGFloat)size;
- (void)callToActionBackgroundColor:(UIColor *)color;
- (void)callToActionTextColor:(UIColor *)color;
- (void)callToActionFontWithName:(NSString *)fontName size:(CGFloat)size;

@end
