//
//  Copyright (c) 2017 PubNative
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNVASTPlayerViewController.h"
#import "PNVASTParser.h"
#import "PNVASTModel.h"
#import "PNVASTMediaFilePicker.h"
#import "PNVASTEventProcessor.h"
#import "PNProgressLabel.h"
#import "UIApplication+TopViewController.h"

NSString * const kPNVASTPlayerStatusKeyPath         = @"status";
NSString * const kPNVASTPlayerBundleName            = @"player.resources";
NSString * const kPNVASTPlayerMuteImageName         = @"PnMute";
NSString * const kPNVASTPlayerUnMuteImageName       = @"PnUnMute";
NSString * const kPNVASTPlayerFullScreenImageName   = @"PnFullScreen";
NSString * const kPNVASTPlayerOpenImageName         = @"PNExternalLink";

NSTimeInterval const kPNVASTPlayerDefaultLoadTimeout        = 20.0f;
NSTimeInterval const kPNVASTPlayerDefaultPlaybackInterval   = 0.25f;

typedef enum : NSUInteger {
    PNVastPlayerState_IDLE = 1 << 0,
    PNVastPlayerState_LOAD = 1 << 1,
    PNVastPlayerState_READY = 1 << 2,
    PNVastPlayerState_PLAY = 1 << 3,
    PNVastPlayerState_PAUSE = 1 << 4
}PNVastPlayerState;

typedef enum : NSUInteger {
    PNVastPlaybackState_FirstQuartile = 1 << 0,
    PNVastPlaybackState_SecondQuartile = 1 << 1,
    PNVastPlaybackState_ThirdQuartile = 1 << 2,
    PNVastPlaybackState_FourthQuartile = 1 << 3
}PNVastPlaybackState;

@interface PNVASTPlayerViewController ()<PNVASTEventProcessorDelegate>

@property (nonatomic, assign) BOOL                  shown;
@property (nonatomic, assign) BOOL                  wantsToPlay;
@property (nonatomic, assign) BOOL                  muted;
@property (nonatomic, assign) BOOL                  fullScreen;
@property (nonatomic, assign) PNVastPlayerState     currentState;
@property (nonatomic, assign) PNVastPlaybackState   playback;
@property (nonatomic, strong) NSURL                 *vastUrl;
@property (nonatomic, strong) NSString              *vastString;
@property (nonatomic, strong) PNVASTModel           *vastModel;
@property (nonatomic, strong) PNVASTParser          *parser;
@property (nonatomic, strong) PNVASTEventProcessor  *eventProcessor;
@property (nonatomic, strong) NSTimer               *loadTimer;
@property (nonatomic, strong) id                    playbackToken;
// Fullscreen
@property (nonatomic, strong) UIView                *viewContainer;
// Player
@property (nonatomic, strong) AVPlayer              *player;
@property (nonatomic, strong) AVPlayerItem          *playerItem;
@property (nonatomic, strong) AVPlayerLayer         *layer;
@property (nonatomic, strong) PNProgressLabel       *progressLabel;
// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton                   *btnMute;
@property (weak, nonatomic) IBOutlet UIButton                   *btnOpenOffer;
@property (weak, nonatomic) IBOutlet UIButton                   *btnFullscreen;
@property (weak, nonatomic) IBOutlet UIView                     *viewProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *loadingSpin;

@end

@implementation PNVASTPlayerViewController

#pragma mark NSObject

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[self getBundle]];
    if (self) {
        self.state = PNVastPlayerState_IDLE;
        self.playback = PNVastPlaybackState_FirstQuartile;
        self.muted = YES;
        self.canResize = YES;
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

#pragma mark UIViewController

- (void)viewWillLayoutSubviews
{
    if(self.layer) {
        self.layer.frame = self.view.bounds;
    }
}

- (void)viewDidLoad
{
    [self.btnMute setImage:[self bundledImageNamed:@"PnMute"] forState:UIControlStateNormal];
    [self.btnOpenOffer setImage:[self bundledImageNamed:@"PNExternalLink"] forState:UIControlStateNormal];
    [self.btnFullscreen setImage:[self bundledImageNamed:@"PnFullScreen"] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.shown = YES;
    if(self.wantsToPlay) {
        [self setState:PNVastPlayerState_PLAY];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.shown = NO;
}

#pragma mark - PUBLIC -

- (void)loadWithVastUrl:(NSURL*)url
{
    @synchronized (self) {
        self.vastUrl = url;
        [self setState:PNVastPlayerState_LOAD];
    }
}

- (void)loadWithVastString:(NSString *)vast
{
    @synchronized (self) {
        self.vastString = vast;
        [self setState:PNVastPlayerState_LOAD];
    }
}

- (void)play
{
    @synchronized (self) {
        [self setState:PNVastPlayerState_PLAY];
    }
}

- (void)pause
{
    @synchronized (self) {
        [self setState:PNVastPlayerState_PAUSE];
    }
}

- (void)stop
{
    @synchronized (self) {
        [self setState:PNVastPlayerState_IDLE];
    }
}

#pragma mark - PRIVATE -

- (void)close
{
    @synchronized (self) {
        [self removeObservers];
        [self stopLoadTimeoutTimer];
        if(self.shown) {
            [self.eventProcessor trackEvent:PNVASTEvent_Close];
        }
        [self.player pause];
        [self.layer removeFromSuperlayer];
        [self.progressLabel removeFromSuperview];
        self.progressLabel = nil;
        self.layer = nil;
        self.playerItem = nil;
        self.player = nil;
        self.vastUrl = nil;
        self.vastString = nil;
        self.vastModel = nil;
        self.parser = nil;
        self.eventProcessor = nil;
        self.viewContainer = nil;
    }
}

- (UIImage*)bundledImageNamed:(NSString*)name
{
    NSBundle *bundle = [self getBundle];
    // Try getting the regular PNG
    NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    // If nil, let's try to get the combined TIFF, JIC it's enabled
    if(imagePath == nil) {
        imagePath = [bundle pathForResource:name ofType:@"tiff"];
    }
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (NSBundle*)getBundle
{
    return [NSBundle bundleForClass:[self class]];
}

- (void)createVideoPlayerWithVideoUrl:(NSURL*)url
{
    [self addObservers];
    // Create asset to be played
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *assetKeys = @[@"playable"];

    // Create a new AVPlayerItem with the asset and an
    // array of asset keys to be automatically loaded
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];

    // Register as an observer of the player item's status property
    [self.playerItem addObserver:self
                      forKeyPath:kPNVASTPlayerStatusKeyPath
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:&_playerItem];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.volume = 0;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    __weak typeof(self) weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(kPNVASTPlayerDefaultPlaybackInterval, NSEC_PER_SEC);
    self.playbackToken = [self.player addPeriodicTimeObserverForInterval:interval
                                                                   queue:nil
                                                              usingBlock:^(CMTime time) {
                                                                  [weakSelf onPlaybackProgressTick];
                                                              }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {

    // Only handle observations for the PlayerItemContext

    if (context != &_playerItem) {

        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

    } else if ([keyPath isEqualToString:@"status"]
               && self.currentState == PNVastPlayerState_LOAD) {

        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                [self setState:PNVastPlayerState_READY];
                [self invokeDidFinishLoading];
                break;
            case AVPlayerItemStatusFailed:
                [self setState:PNVastPlayerState_IDLE];
                [self invokeDidFailLoadingWithError:self.playerItem.error];
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

- (void)onPlaybackProgressTick
{
    Float64 currentDuration = [self duration];
    Float64 currentPlaybackTime = [self currentPlaybackTime];
    Float64 currentPlayedPercent = currentPlaybackTime / currentDuration;

    [self.progressLabel setProgress:currentPlayedPercent];
    self.progressLabel.text = [NSString stringWithFormat:@"%.f", currentDuration - currentPlaybackTime];

    switch (self.playback) {
        case PNVastPlaybackState_FirstQuartile:
        {
            if (currentPlayedPercent>0.25f) {
                [self.eventProcessor trackEvent:PNVASTEvent_FirstQuartile];
                self.playback = PNVastPlaybackState_SecondQuartile;
            }
        }
        break;
        case PNVastPlaybackState_SecondQuartile:
        {
            if (currentPlayedPercent>0.50f) {
                [self.eventProcessor trackEvent:PNVASTEvent_Midpoint];
                self.playback = PNVastPlaybackState_ThirdQuartile;
            }
        }
        break;
        case PNVastPlaybackState_ThirdQuartile:
        {
            if (currentPlayedPercent>0.75f) {
                [self.eventProcessor trackEvent:PNVASTEvent_ThirdQuartile];
                self.playback = PNVastPlaybackState_FourthQuartile;
            }
        }
        break;
        default: break;
    }
}

- (Float64)duration
{
    AVPlayerItem *currentItem = self.player.currentItem;
    return CMTimeGetSeconds([currentItem duration]);
}

- (Float64)currentPlaybackTime
{
    AVPlayerItem *currentItem = self.player.currentItem;
    return CMTimeGetSeconds([currentItem currentTime]);
}

- (void)trackError
{
    NSLog(@"VASTPlayer - Sending Error requests");
    if(self.vastModel && [self.vastModel errors] != nil) {
        [self.eventProcessor sendVASTUrls:[self.vastModel errors]];
    }
}

#pragma mark IBActions

- (IBAction)btnMutePush:(id)sender {

    NSLog(@"btnMutePush");
    self.muted = !self.muted;
    NSString *newImageName = self.muted ? @"PnMute" : @"PnUnMute";
    UIImage *newImage = [self bundledImageNamed:newImageName];
    [self.btnMute setImage:newImage forState:UIControlStateNormal];
    CGFloat newVolume = self.muted?0.0f:1.0f;
    self.player.volume = newVolume;
}

- (IBAction)btnOpenOfferPush:(id)sender {

    NSLog(@"btnOpenOfferPush");
    NSArray *clickTrackingUrls = [self.vastModel clickTracking];
    if (clickTrackingUrls != nil && [clickTrackingUrls count] > 0) {
        [self.eventProcessor sendVASTUrls:clickTrackingUrls];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.vastModel clickThrough]]];
}

- (IBAction)btnFullscreenPush:(id)sender {

    NSLog(@"btnFullscreenPush");

    self.fullScreen = !self.fullScreen;
    if (self.fullScreen) {

        self.viewContainer = self.view.superview;
        [self.view removeFromSuperview];
        self.view.frame = [UIApplication sharedApplication].topViewController.view.frame;
        [[UIApplication sharedApplication].topViewController.view addSubview:self.view];
        
    } else {

        [self.view removeFromSuperview];
        self.view.frame = self.viewContainer.bounds;
        [self.viewContainer addSubview:self.view];
    }
}

#pragma mark - Delegate helpers

- (void)invokeDidFinishLoading
{
    [self stopLoadTimeoutTimer];
    if([self.delegate respondsToSelector:@selector(vastPlayerDidFinishLoading:)]) {
        [self.delegate vastPlayerDidFinishLoading:self];
    }
}

- (void)invokeDidFailLoadingWithError:(NSError*)error
{
    [self close];
    if([self.delegate respondsToSelector:@selector(vastPlayer:didFailLoadingWithError:)]) {
        [self.delegate vastPlayer:self didFailLoadingWithError:error];
    }
    [self trackError];
}

- (void)invokeDidStartPlaying
{
    if([self.delegate respondsToSelector:@selector(vastPlayerDidStartPlaying:)]) {
        [self.delegate vastPlayerDidStartPlaying:self];
    }
}

- (void)invokeDidPause
{
    if([self.delegate respondsToSelector:@selector(vastPlayerDidPause:)]) {
        [self.delegate vastPlayerDidPause:self];
    }
}

- (void)invokeDidComplete
{
    if([self.delegate respondsToSelector:@selector(vastPlayerDidComplete:)]) {
        [self.delegate vastPlayerDidComplete:self];
    }
}

#pragma mark - AVPlayer notifications

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player];
}

- (void)removeObservers
{
    if(self.player != nil) {
        [self.playerItem removeObserver:self forKeyPath:kPNVASTPlayerStatusKeyPath];
        [self.player removeTimeObserver:self.playbackToken];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    if(self.currentState == PNVastPlayerState_PLAY) {
        [self.player play];
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    [self.eventProcessor trackEvent:PNVASTEvent_Complete];
    if(self.fullScreen) {
        [self btnFullscreenPush:self.btnFullscreen];
    }
    [self.player pause];
    [self.playerItem seekToTime:kCMTimeZero];
    [self setState:PNVastPlayerState_READY];
    [self invokeDidComplete];
}

#pragma mark - State Machine

- (BOOL)canGoToState:(PNVastPlayerState)state
{
    BOOL result = NO;

    switch (state) {
        case PNVastPlayerState_IDLE:    result = YES; break;
        case PNVastPlayerState_LOAD:    result = self.currentState & PNVastPlayerState_IDLE; break;
        case PNVastPlayerState_READY:   result = self.currentState & (PNVastPlayerState_PLAY|PNVastPlayerState_LOAD); break;
        case PNVastPlayerState_PLAY:
        {
            if ((self.currentState & PNVastPlayerState_READY) && !self.shown) {
                self.wantsToPlay = YES;
                NSLog(@"PNVASTPlayer - You're trying to play when the view is not add to the screen, it will be played as soon as the view is add to the screen");
            }
            result = (self.currentState & (PNVastPlayerState_READY|PNVastPlayerState_PAUSE)) && self.shown;
        }
        break;
        case PNVastPlayerState_PAUSE:   result = (self.currentState & PNVastPlayerState_PLAY) && self.shown; break;
        default: break;
    }

    return result;
}

- (void)setState:(PNVastPlayerState)state
{
    if ([self canGoToState:state]) {
        self.currentState = state;
        switch (self.currentState) {
            case PNVastPlayerState_IDLE:    [self setIdleState];    break;
            case PNVastPlayerState_LOAD:    [self setLoadState];    break;
            case PNVastPlayerState_READY:   [self setReadyState];   break;
            case PNVastPlayerState_PLAY:    [self setPlayState];    break;
            case PNVastPlayerState_PAUSE:   [self setPauseState];   break;
        }
    } else {
        NSLog(@"PNVastPlayer - Cannot go to state %lu, invalid previous state", (unsigned long)state);
    }
}

- (void)setIdleState
{
    NSLog(@"PNVastPlayer - setIdleState");

    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = YES;
    self.btnOpenOffer.hidden = YES;
    self.btnFullscreen.hidden = YES;
    self.viewProgress.hidden = YES;
    self.wantsToPlay = NO;
    [self.loadingSpin stopAnimating];

    [self close];
}

- (void)setLoadState
{
    NSLog(@"PNVastPlayer - setLoadState");

    self.loadingSpin.hidden = NO;
    self.btnMute.hidden = YES;
    self.btnOpenOffer.hidden = YES;
    self.btnFullscreen.hidden = YES;
    self.viewProgress.hidden = YES;
    self.wantsToPlay = NO;
    [self.loadingSpin startAnimating];

    if (self.vastUrl == nil && self.vastString == nil) {

        NSLog(@"PNVastPlayer - setLoadState error: VAST is nil and required");
        [self setState:PNVastPlayerState_IDLE];

    } else {

        if (self.parser == nil) {
            self.parser = [[PNVASTParser alloc] init];
        }

        [self startLoadTimeoutTimer];

        __weak PNVASTPlayerViewController *weakSelf = self;
        vastParserCompletionBlock completion = ^(PNVASTModel *model, PNVASTParserError error) {
            if (model == nil) {
                NSError *parseError = [NSError errorWithDomain:[NSString stringWithFormat:@"%ld", (long)error]
                                                          code:0
                                                      userInfo:nil];
                [weakSelf invokeDidFailLoadingWithError:parseError];
            } else {
                weakSelf.eventProcessor = [[PNVASTEventProcessor alloc] initWithEvents:[model trackingEvents] delegate:self];
                NSURL *mediaUrl = [PNVASTMediaFilePicker pick:[model mediaFiles]].url;
                if(mediaUrl == nil) {
                    NSLog(@"PNVASTPlayerVC - Error: did not find a compatible mediaFile");
                    NSError *mediaNotFoundError = [NSError errorWithDomain:@"PNVASTPlayerVC - Error: Not found compatible media with this device" code:0 userInfo:nil];
                    [weakSelf invokeDidFailLoadingWithError:mediaNotFoundError];
                } else {
                    weakSelf.vastModel = model;
                    [weakSelf createVideoPlayerWithVideoUrl:mediaUrl];
                }
            }
        };

        if (self.vastUrl != nil) {
            [self.parser parseWithUrl:self.vastUrl
                           completion:completion];
        } else if (self.vastString != nil) {
            [self.parser parseWithData:[self.vastString dataUsingEncoding:NSUTF8StringEncoding]
                            completion:completion];
        } else {
            NSError *unexpectedError = [NSError errorWithDomain:@"PNVASTPlayerVC - Error: unexpected" code:0 userInfo:nil];
            [self invokeDidFailLoadingWithError:unexpectedError];
        }
    }
}

- (void)setReadyState
{
    NSLog(@"PNVastPlayer - setReadyState");
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = YES;
    self.btnOpenOffer.hidden = YES;
    self.btnFullscreen.hidden = YES;
    self.viewProgress.hidden = YES;
    self.loadingSpin.hidden = YES;

    if(self.layer == nil) {
        self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.layer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.layer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.layer atIndex:0];
    }

    if(self.progressLabel == nil) {
        self.progressLabel = [[PNProgressLabel alloc] initWithFrame:self.viewProgress.bounds];
        self.progressLabel.frame = self.viewProgress.bounds;
        self.progressLabel.borderWidth = 6.0;
        self.progressLabel.colorTable = @{
                                          NSStringFromPNProgressLabelColorTableKey(PNColorTable_ProgressLabelTrackColor):[UIColor clearColor],
                                          NSStringFromPNProgressLabelColorTableKey(PNColorTable_ProgressLabelProgressColor):[UIColor whiteColor],
                                          NSStringFromPNProgressLabelColorTableKey(PNColorTable_ProgressLabelFillColor):[UIColor clearColor]
                                         };
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.shadowColor = [UIColor darkGrayColor];
        self.progressLabel.shadowOffset = CGSizeMake(1, 1);
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.font = [UIFont fontWithName:@"Helvetica" size:12];

        [self.progressLabel setProgress:0.0f];
        [self.viewProgress addSubview:self.progressLabel];
    }
    self.progressLabel.text = @"0";
}

- (void)setPlayState
{
    NSLog(@"PNVastPlayer - setPlayState");

    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = NO;
    self.btnOpenOffer.hidden = NO;
    self.btnFullscreen.hidden = !self.canResize;
    self.viewProgress.hidden = NO;
    self.wantsToPlay = NO;
    [self.loadingSpin stopAnimating];

    // Start playback
    [self.player play];
    if([self currentPlaybackTime]  > 0) {
        [self.eventProcessor trackEvent:PNVASTEvent_Resume];
    } else {
        [self.eventProcessor trackEvent:PNVASTEvent_Start];
    }
    [self invokeDidStartPlaying];
}

- (void)setPauseState
{
    NSLog(@"PNVastPlayer - setPauseState");

    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = NO;
    self.btnOpenOffer.hidden = NO;
    self.btnFullscreen.hidden = !self.canResize;
    self.viewProgress.hidden = NO;
    [self.loadingSpin stopAnimating];

    [self.player pause];
    [self.eventProcessor trackEvent:PNVASTEvent_Pause];
    [self invokeDidPause];
}

#pragma mark - TIMERS -
#pragma mark Load timer

- (void)startLoadTimeoutTimer
{
    @synchronized (self) {
        [self stopLoadTimeoutTimer];
        if(self.loadTimeout == 0) {
            self.loadTimeout = kPNVASTPlayerDefaultLoadTimeout;
        }

        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:self.loadTimeout
                                                          target:self
                                                        selector:@selector(loadTimeoutFired)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)stopLoadTimeoutTimer
{
    [self.loadTimer invalidate];
    self.loadTimer = nil;
}

- (void)loadTimeoutFired
{
    [self close];
    NSError *error = [NSError errorWithDomain:@"VASTPlayer - video load timeout" code:0 userInfo:nil];
    [self invokeDidFailLoadingWithError:error];
}

#pragma mark - CALLBACKS -
#pragma mark PNVASTEventProcessorDelegate

- (void)eventProcessorDidTrackEvent:(PNVASTEvent)event
{
    NSLog(@"PNVastPlayer - event tracked: %ld", (long)event);
}

@end
