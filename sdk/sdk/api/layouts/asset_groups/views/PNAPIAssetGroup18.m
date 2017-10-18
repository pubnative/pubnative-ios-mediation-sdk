//
//  PNAPIAssetGroup18.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup18.h"
#import "PNVASTPlayerViewController.h"

@interface PNAPIAssetGroup18 () <PNVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *adText;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *cta;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (nonatomic, strong) PNVASTPlayerViewController *player;
@property (weak, nonatomic) IBOutlet UIView *contentInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation PNAPIAssetGroup18

- (void)dealloc
{
    [self.player stop];
    self.player = nil;
}

- (void)load
{
    self.adTitle.text = self.model.title;
    self.body.text = self.model.body;
    self.cta.layer.cornerRadius = kPNCTACornerRadius;
    [self.cta setTitle:self.model.callToAction forState:UIControlStateNormal];
    self.icon.layer.cornerRadius = kPNCTACornerRadius;
    [self.contentInfoView addSubview:self.model.contentInfo];
    
    __block NSURL *iconURL = [NSURL URLWithString:self.model.iconUrl];
    __block PNAPIAssetGroup18 *strongSelf = self;
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
                    [strongSelf loadVideo];
                }
            }
            strongSelf = nil;
            data = nil;
        });
        iconURL = nil;
    });
}

- (void)loadVideo
{
    self.player = [[PNVASTPlayerViewController alloc] init];
    self.player.delegate = self;
    [self.player loadWithVastString:self.model.vast];
}

- (void)updateContentInfoSize:(NSNotification *)notification
{
    NSNumber *contentInfoSize = notification.object;
    self.widthConstraint.constant = [contentInfoSize floatValue];
    [self.view layoutIfNeeded];
}

- (void)startTracking
{
    [self.model setDelegate:self];
    [self.player play];
    [self.model startTrackingView:self.view];
}

- (void)stopTracking
{
    [self.player stop];
    [self.model stopTracking];
}

#pragma mark - CALLBACKS -
#pragma mark PNVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNVASTPlayerViewController *)vastPlayer
{
    vastPlayer.view.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:vastPlayer.view];
    [self invokeLoadFinish];
}

- (void)vastPlayer:(PNVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error
{
    [self invokeLoadFail:error];
}

- (void)vastPlayerDidStartPlaying:(PNVASTPlayerViewController *)vastPlayer
{
    // Do nothing
}

- (void)vastPlayerDidPause:(PNVASTPlayerViewController *)vastPlayer
{
    // Do nothing
}

- (void)vastPlayerDidComplete:(PNVASTPlayerViewController *)vastPlayer
{
    // Do nothing
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
