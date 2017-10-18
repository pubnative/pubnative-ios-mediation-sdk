//
//  PNAPIAssetGroup15.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup15.h"
#import "PNVASTPlayerViewController.h"

@interface PNAPIAssetGroup15 () <PNVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (nonatomic, strong) PNVASTPlayerViewController *player;
@property (weak, nonatomic) IBOutlet UIView *contentInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation PNAPIAssetGroup15

- (void)dealloc
{
    [self.player stop];
    self.player = nil;
}

- (void)load
{
    [self.contentInfoView addSubview:self.model.contentInfo];
    [self loadVideo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.player stop];
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

@end
