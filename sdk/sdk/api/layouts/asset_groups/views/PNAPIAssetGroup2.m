//
//  PNAPIAssetGroup2.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup2.h"

@interface PNAPIAssetGroup2 ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIButton *cta;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *adText;
@property (weak, nonatomic) IBOutlet UILabel *body;

@end

@implementation PNAPIAssetGroup2

- (void)load
{
    self.adTitle.text = self.model.title;
    self.body.text = self.model.body;
    self.cta.layer.cornerRadius = kPNCTACornerRadius;
    [self.cta setTitle:self.model.callToAction forState:UIControlStateNormal];
    self.icon.layer.cornerRadius = kPNCTACornerRadius;
    self.adText.layer.cornerRadius = kPNCTACornerRadius;
    
    __block NSURL *iconURL = [NSURL URLWithString:self.model.iconUrl];
    __block PNAPIAssetGroup2 *strongSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSData *data = [NSData dataWithContentsOfURL:iconURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data == nil) {
                [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get data"
                                                               code:0
                                                           userInfo:nil]];
            } else {
                UIImage *image = [UIImage imageWithData:data];
                if(image == nil) {
                    [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get image"
                                                                   code:0
                                                               userInfo:nil]];
                } else {
                    strongSelf.icon.image = image;
                    [strongSelf invokeLoadFinish];
                }
            }
            strongSelf = nil;
            data = nil;
        });
        iconURL = nil;
    });

    
}

- (void)startTracking
{
    [self.model setDelegate:self];
    [self.model startTrackingView:self.view];
}

- (void)stopTracking
{
    [self.model stopTracking];
}

#pragma mark - PNLayoutViewController -

- (void)adBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

- (void)titleTextColor:(UIColor *)color
{
    self.adTitle.textColor = color;
}

- (void)titleFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.adTitle setFont:[UIFont fontWithName:fontName size:size]];
}

- (void)descriptionTextColor:(UIColor *)color
{
    self.body.textColor = color;
}

- (void)descriptionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.body setFont:[UIFont fontWithName:fontName size:size]];
}

- (void)callToActionBackgroundColor:(UIColor *)color
{
    self.cta.backgroundColor = color;
}

- (void)callToActionTextColor:(UIColor *)color
{
    [self.cta setTitleColor:color forState:UIControlStateNormal];
}

- (void)callToActionFontWithName:(NSString *)fontName size:(CGFloat)size
{
    [self.cta.titleLabel setFont:[UIFont fontWithName:fontName size:size]];
}

@end
