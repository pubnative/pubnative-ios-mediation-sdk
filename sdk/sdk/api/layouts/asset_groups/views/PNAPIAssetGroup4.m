//
//  PNAPIAssetGroup4.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup4.h"
#import "PNVASTPlayerViewController.h"

@interface PNAPIAssetGroup4 () <PNVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (nonatomic, strong) PNVASTPlayerViewController *player;

@end

@implementation PNAPIAssetGroup4

- (void)dealloc
{
    [self.player stop];
    self.player = nil;
}

- (void)load
{
    [self loadVideo];
}

- (void)loadVideo
{
    self.player = [[PNVASTPlayerViewController alloc] init];
    self.player.delegate = self;
    [self.player loadWithVastString:self.model.vast];
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

@end
