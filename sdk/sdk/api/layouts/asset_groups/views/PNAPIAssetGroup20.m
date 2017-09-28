//
//  PNAPIAssetGroup20.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup20.h"
#import "PNVASTPlayerViewController.h"

@interface PNAPIAssetGroup20 () <PNVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (weak, nonatomic) IBOutlet UIButton *cta;
@property (weak, nonatomic) IBOutlet UILabel *adText;
@property (strong, nonatomic) PNVASTPlayerViewController *player;
@property (strong, nonatomic) NSData *iconData;

@end

@implementation PNAPIAssetGroup20

#pragma mark NSObject

- (void)dealloc
{
    [self.player stop];
    self.player = nil;
    self.iconData = nil;
}

#pragma mark PNAPIAssetGroup

- (void)load
{
    self.adTitle.text = self.model.title;
    self.body.text = self.model.body;
    self.cta.layer.cornerRadius = kPNCTACornerRadius;
    [self.cta setTitle:self.model.callToAction forState:UIControlStateNormal];
    self.icon.layer.cornerRadius = kPNCTACornerRadius;
    
    if (self.iconData) {
        [self continueLoadingWithIconData:self.iconData];
    } else {
        [self loadIconData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.player stop];
}

- (void)loadIconData
{
    __block PNAPIAssetGroup20 *strongSelf = self;
    __block NSURL *iconURL = [NSURL URLWithString:self.model.iconUrl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        strongSelf.iconData = [NSData dataWithContentsOfURL:iconURL];
        [self continueLoadingWithIconData:strongSelf.iconData];
        iconURL = nil;
        strongSelf = nil;
    });
}

- (void)continueLoadingWithIconData:(NSData *)iconData
{
    __block PNAPIAssetGroup20 *strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *iconImage = [UIImage imageWithData:iconData];
        if(iconImage == nil) {
            [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get icon image"
                                                           code:0
                                                       userInfo:nil]];
        } else {
            strongSelf.icon.image = iconImage;
            [strongSelf loadVideo];
        }
        strongSelf = nil;
    });
}

- (void)loadVideo
{
    if (self.player == nil) {
        self.player = [[PNVASTPlayerViewController alloc] init];
        self.player.delegate = self;
        [self.player loadWithVastString:self.model.vast];
    } else {
        [self addVideoPlayer];
    }
}

- (void)addVideoPlayer
{
    self.player.view.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:self.player.view];
}

#pragma mark - Callbacks -

#pragma mark PNVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNVASTPlayerViewController*)vastPlayer
{
    [self addVideoPlayer];
    [self invokeLoadFinish];
}

- (void)vastPlayer:(PNVASTPlayerViewController*)vastPlayer didFailLoadingWithError:(NSError*)error
{
    [self invokeLoadFail:error];
}

- (void)vastPlayerDidStartPlaying:(PNVASTPlayerViewController*)vastPlayer
{
    // Do nothing
}

- (void)vastPlayerDidPause:(PNVASTPlayerViewController*)vastPlayer
{
    // Do nothing
}

- (void)vastPlayerDidComplete:(PNVASTPlayerViewController*)vastPlayer
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
