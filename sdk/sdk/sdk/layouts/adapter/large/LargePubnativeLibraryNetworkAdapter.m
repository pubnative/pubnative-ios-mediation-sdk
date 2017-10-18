//
//  LargePubnativeLibraryNetworkAdapter.m
//  sdk
//
//  Created by Can Soykarafakili on 05.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "LargePubnativeLibraryNetworkAdapter.h"
#import "PNOrientationManager.h"
#import "PNLargeLayoutContainerViewController.h"
#import "PubnativeLibraryCPICache.h"
#import "PNAdModel.h"
#import "PNSettings.h"
#import "PNAPILayout.h"
#import "PNError.h"
#import "UIApplication+TopViewController.h"


@interface LargePubnativeLibraryNetworkAdapter () <PNAPILayoutFetchDelegate, PNAPILayoutLoadDelegate, PNAPIAdModelDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIWindow *currentWindow;
@property (nonatomic, strong) UIViewController *containerViewController;
@property (nonatomic, strong) PNAPILayout *layout;

@end

@implementation LargePubnativeLibraryNetworkAdapter

- (void)dealloc
{
    [self.closeButton removeFromSuperview];
    self.closeButton = nil;
    self.layout = nil;
    [self.containerViewController willMoveToParentViewController:nil];
    self.containerViewController = nil;
    self.currentWindow = nil;
}

- (void)request:(NSDictionary *)networkData
{
    if (networkData == nil || networkData.count == 0) {
        [self invokeDidFailLoadingWithError:[PNError errorWithCode:PNError_adapter_illegalArguments]];
    } else {
        
        self.containerViewController = nil;
        
        self.layout = [[PNAPILayout alloc] init];
        for (NSString *key in networkData) {
            NSString *value = [networkData objectForKey:key];
            [self.layout addParameterWithKey:key value:value];
        }
        if ([PNSettings sharedInstance].targeting) {
            NSDictionary *targetingDictionary = [[PNSettings sharedInstance].targeting toDictionary];
            for (NSString *key in targetingDictionary) {
                NSString *value = [targetingDictionary objectForKey:key];
                [self.layout addParameterWithKey:key value:value];
            }
        }
        [self.layout setCoppaMode:[PNSettings sharedInstance].coppa];
        [self.layout setTestMode:[PNSettings sharedInstance].test];
        [self.layout loadWithSize:LARGE loadDelegate:self];
    }
}

- (void)fetch
{
    [self.layout fetchWithDelegate:self];
}

#pragma mark - Protocols -
#pragma mark PNLayoutFullscreenAdapterProtocol

- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotateNotification:)
                                                 name:kPNOrientationManagerDidChangeOrientation
                                               object:nil];
    
    [self addCloseButton];
    [self startTracking];
    
    [[UIApplication sharedApplication].topViewController presentViewController:self.containerViewController animated:NO completion:nil];
    
    [self invokeDidShow];
}

- (void)didRotateNotification:(NSNotification *)notification
{
    [self addCloseButton];
}

- (void)startTracking
{
    if(self.layout && self.layout.model && self.containerViewController) {
        [self.layout.model setDelegate:self];
        [self.layout.model startTrackingView:self.containerViewController.view];
    }
}

- (void)hide
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self stopTracking];
    
    [[UIApplication sharedApplication].topViewController dismissViewControllerAnimated:self.containerViewController completion:nil];
    
    [self invokeDidHide];
}

- (void)stopTracking
{
    [self.layout.model stopTracking];
    [self.layout.model setDelegate:nil];
}

- (void)addCloseButton
{
    if(self.closeButton == nil) {
        self.closeButton = [[UIButton alloc] init];
        self.closeButton.backgroundColor = [UIColor clearColor];
        [self.closeButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                                     pathForResource:@"PNCloseIcon"
                                                                     ofType:@"png"]]
                          forState:UIControlStateNormal];
        
        [self.closeButton addTarget:self
                             action:@selector(closeTouchedUpInside:)
                   forControlEvents:UIControlEventTouchUpInside];
        
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSLayoutConstraint * trailingConstraint =[NSLayoutConstraint constraintWithItem:self.containerViewController.view
                                                                          attribute:NSLayoutAttributeRight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.closeButton
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1.0 constant:10];
    
    NSLayoutConstraint * topConstraint =[NSLayoutConstraint constraintWithItem:self.containerViewController.view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.closeButton
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0 constant:-1*10];
    
    NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:self.closeButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:0
                                                                       multiplier:1.0
                                                                         constant:29];
    
    NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:self.closeButton
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:0
                                                                        multiplier:1.0
                                                                          constant:29];
    
    [self.closeButton removeFromSuperview];
    [self.containerViewController.view addSubview:self.closeButton];
    [self.containerViewController.view addConstraints:@[trailingConstraint, topConstraint]];
    [self.closeButton addConstraints:@[widthConstraint, heightConstraint]];
}

- (void)closeTouchedUpInside:(UIView*)sender
{
    [self hide];
}

#pragma mark - Delegates -
#pragma mark PNAPILayoutLoadDelegate

- (void)layout:(PNAPILayout *)layout loadDidFinish:(PNAPIAdModel *)model
{
    if (model.isRevenueModelCPA && self.isCPICacheEnabled) {
        PNAPIAdModel *cachedAdModel = [PubnativeLibraryCPICache get];
        if (cachedAdModel) {
            layout.model = model;
        }
    }
    [self invokeDidFinishLoading];
}

- (void)layout:(PNAPILayout *)layout loadDidFail:(NSError *)error
{
    if (self.isCPICacheEnabled) {
        PNAPIAdModel *cachedAdModel = [PubnativeLibraryCPICache get];
        if (cachedAdModel == nil) {
            [self invokeDidFailLoadingWithError:error];
        } else {
            layout.model = cachedAdModel;
            [self invokeDidFinishLoading];
        }
    } else {
        [self invokeDidFailLoadingWithError:error];
    }
}

#pragma mark PNAPILayoutFetchDelegate

- (void)layout:(PNAPILayout *)layout fetchDidFinish:(PNAPILayoutViewController *)viewController
{
    self.containerViewController = [[PNLargeLayoutContainerViewController alloc] initWithViewController:viewController];
    [self invokeDidFinishFetching];
}

- (void)layout:(PNAPILayout *)layout fetchDidFail:(NSError *)error
{
    [self invokeDidFailFetchingWithError:error];
}


#pragma mark PNAPIAdModelDelegate

- (void)adModel:(PNAPIAdModel*)model impressionConfirmedWithView:(UIView*)view
{
    [self invokeImpression];
}

- (void)adModelDidClick:(PNAPIAdModel*)model
{
    [self invokeClick];
}

@end
