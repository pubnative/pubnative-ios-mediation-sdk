//
//  Copyright © 2016 PubNative. All rights reserved.
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

#import "PNAPIAdModel.h"
#import "PNAPIDriller.h"
#import "PNAPIMeta.h"
#import "PNAPIImpressionTracker.h"
#import "PNAPITrackingManager.h"
#import "PNAPIClickCacher.h"

NSString * const kPNAPIAdModelBeaconImpression = @"impression";
NSString * const kPNAPIAdModelBeaconClick      = @"click";

@interface PNAPIAdModel () <PNAPIDrillerDelegate, PNAPIImpressionTrackerDelegate, PNAPIClickCacherDelegate>

@property (nonatomic, weak)NSObject<PNAPIAdModelDelegate>   *delegate;
@property (nonatomic, strong)UIView                         *loader;
@property (nonatomic, strong)PNAPIV3AdModel                 *data;
@property (nonatomic, strong)PNAPIImpressionTracker         *impressionTracker;
@property (nonatomic, strong)UITapGestureRecognizer         *tapRecognizer;
@property (nonatomic, strong)NSArray                        *clickableViews;
@property (nonatomic, strong)NSString                       *uuid;
@property (nonatomic, strong)NSString                       *clickRedirectionFinalURL;
@property (nonatomic, strong)PNAPIClickCacher               *clickCacher;
@property (nonatomic, strong)PNAPIContentView               *contentInfoView;
@property (nonatomic, strong)NSDictionary                   *trackingExtras;
@property (nonatomic, assign)BOOL                           isImpressionConfirmed;
@property (nonatomic, assign)BOOL                           isClickCachingEnabled;
@property (nonatomic, assign)BOOL                           isClickBackgroundRedirectionEnabled;
@property (nonatomic, assign)BOOL                           isClickLoaderEnabled;
@property (nonatomic, assign)BOOL                           isWaitingForClick;
@property (nonatomic, assign)BOOL                           isPreparingClick;

@end

@implementation PNAPIAdModel

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    [self.loader removeFromSuperview];
    self.loader = nil;
    self.data = nil;
    [self.impressionTracker clear];
    self.impressionTracker = nil;
    [self.tapRecognizer removeTarget:self action:@selector(handleTap:)];
    self.trackingExtras = nil;
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
    self.tapRecognizer = nil;
    self.clickableViews = nil;
    self.uuid = nil;
    self.clickRedirectionFinalURL = nil;
    self.clickCacher = nil;
    self.contentInfoView = nil;
}

#pragma mark
#pragma mark PNAPIAdModel
#pragma mark
#pragma mark public

- (instancetype)initWithData:(PNAPIV3AdModel *)data
{
    return [self initWithData:data extras:nil];
}

- (instancetype)initWithData:(PNAPIV3AdModel *)data extras:(NSDictionary *)extras
{
    self = [super init];
    if (self){
        self.isWaitingForClick = NO;
        self.isClickCachingEnabled = NO;
        self.isClickBackgroundRedirectionEnabled = YES;
        self.isClickLoaderEnabled = YES;
        self.isPreparingClick = NO;
        self.data = data;
    }
    return self;
}

- (BOOL)isRevenueModelCPA
{
    BOOL result = false;
    NSString *revenueModel = [self revenueModel];
    if([revenueModel isEqualToString:@"cpa"]) {
        result = true;
    }
    return result;
}

- (void)setDelegate:(NSObject<PNAPIAdModelDelegate> *)delegate
{
    _delegate = delegate;
}

- (void)setTrackingExtras:(NSDictionary *)extras
{
    _trackingExtras = extras;
}

- (void)fetch
{
    [self prepareClickURL];
}

- (void)startTrackingView:(UIView*)view
{
    [self startTrackingView:view clickableViews:nil];
}

- (void)startTrackingView:(UIView*)view clickableViews:(NSArray*)clickableViews
{
    [self startTrackingImpressionWithView:view];
    [self startTrackingClicksWithView:view clickableViews:clickableViews];
}

- (void)stopTracking
{
    [self stopTrackingImpression];
    [self stopTrackingClicks];
}

#pragma mark properties

- (NSString*)title
{
    return [self textAssetWithType:@"title"];
}

- (NSString*)body
{
    return [self textAssetWithType:@"description"];
}

- (NSString*)callToAction
{
    return [self textAssetWithType:@"cta"];
}

- (NSString*)iconUrl
{
    NSString *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:@"icon"];
    
    if (data) {
        result = data.url;
    }
    return result;
}

- (NSString*)vast
{
    return [self vastAssetWithType:@"vast2"]; 
}

- (NSString*)bannerUrl
{
    NSString *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:@"banner"];
    if (data) {
        result = data.url;
    }
    return result;
}

- (NSString*)standardBannerUrl
{
    NSString *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:@"standardbanner"];
    if (data) {
        result = data.url;
    }
    return result;
}

-(NSString *)htmlUrl
{
    NSString *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:@"htmlbanner"];
    if (data) {
        result = data.html;
    }
    return result;
}

- (NSString*)clickUrl
{
    NSString *result = nil;
    if (self.data) {
        NSURL *clickURL = [NSURL URLWithString:self.data.link];
        result = [self injectExtrasWithUrl:clickURL].absoluteString;
    }
    return result;
}

- (NSNumber*)rating
{
    return [self numberAssetWithType:@"rating"];
}

- (UIView*)contentInfo
{
    PNAPIV3DataModel *contentInfoData = [self metaDataWithType:PNAPIMeta.contentInfo];
    if(contentInfoData == nil) {
        NSLog(@"content info data not found in the returned metadata");
    } else if(self.contentInfoView == nil) {
        self.contentInfoView = [[PNAPIContentView alloc] init];
        self.contentInfoView.text = contentInfoData.text;
        self.contentInfoView.link = [contentInfoData stringFieldWithKey:@"link"];
        self.contentInfoView.icon = [contentInfoData stringFieldWithKey:@"icon"];
    }
    return self.contentInfoView;
}

- (NSNumber *)assetGroupID
{
    NSNumber *result = nil;
    if (self.data) {
        result = self.data.assetgroupid;
    }
    return result;
}

#pragma mark Tracking

- (void)startTrackingImpressionWithView:(UIView*)view
{
    if (view == nil) {
        NSLog(@"startTrackingImpression - ad view is null, cannot start tracking");
    } else if (self.isImpressionConfirmed) {
        NSLog(@"startTrackingImpression - impression is already confirmed, dropping impression tracking");
    } else {
        // Impression tracking
        if(self.impressionTracker == nil) {
            self.impressionTracker = [[PNAPIImpressionTracker alloc] init];
            [self.impressionTracker setDelegate:self];
        }
        
        [self.impressionTracker addView:view];
    }
}

- (void)startTrackingClicksWithView:(UIView*)view clickableViews:(NSArray*)clickableViews
{
    if (view == nil && clickableViews == nil) {
        NSLog(@"startTrackingClicks - Error: click view is null, clicks won't be tracked");
    } else if (!self.clickUrl || self.clickUrl.length == 0) {
        NSLog(@"startTrackingClicks - Error: click url is empty, clicks won't be tracked");
    } else {
        
        [self prepareClickURL];
        
        self.clickableViews = [clickableViews mutableCopy];
        if(self.clickableViews == nil) {
            self.clickableViews = [NSArray arrayWithObjects:view, nil];
        }
        
        if(self.tapRecognizer == nil) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        }
        
        for (UIView *clickableView in self.clickableViews) {
            clickableView.userInteractionEnabled=YES;
            [clickableView addGestureRecognizer:self.tapRecognizer];
        }
    }
}

- (void)prepareClickURL
{
    // We can do this only if it's enabled, Revenue model is CPI and wasn't already prepared
    if([self isRevenueModelCPA]
       && self.isClickCachingEnabled
       && !self.isPreparingClick
       && self.clickRedirectionFinalURL == nil) {
        self.isPreparingClick = YES;
        self.uuid = [[NSUUID UUID] UUIDString];
        NSString *url = [NSString stringWithFormat:@"%@&uxc=true&uuid=%@", self.clickUrl, self.uuid];
        if(self.clickCacher == nil) {
            self.clickCacher = [[PNAPIClickCacher alloc] init];
        }
        [self.clickCacher cacheWithURLString:url delegate:self];
    }
}

- (void)stopTrackingImpression
{
    [self.impressionTracker clear];
    self.impressionTracker = nil;
}

- (void)stopTrackingClicks
{
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if(self.isClickLoaderEnabled) {
            [self showLoaderView];
        }
        
        [self invokeClick];
        [self confirmBeaconsWithType:kPNAPIAdModelBeaconClick];
        
        if (self.isClickBackgroundRedirectionEnabled) {
        
            if ([self isRevenueModelCPA] && self.isClickCachingEnabled) {
                if(self.clickRedirectionFinalURL) {
                    [self openCachedClick];
                } else {
                    self.isWaitingForClick = YES;
                }
            } else {
                [[[PNAPIDriller alloc] init] startDrillWithURLString:self.clickUrl delegate:self];
            }
        } else {
            
            [self openURLString:self.clickUrl];
        }
    }
}

- (void)openCachedClick
{
    NSString *url = [NSString stringWithFormat:@"%@&cached=true&uuid=%@", self.clickUrl, self.uuid];
    [[[PNAPIDriller alloc] init] startDrillWithURLString:url delegate:self];
    [self openURLString:self.clickRedirectionFinalURL];
}

- (void)openURLString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark PNAPIAdModelClickConfiguration

- (void)setClickCaching:(BOOL)enabled
{
    self.isClickCachingEnabled = enabled;
}

- (void)setClickLoader:(BOOL)enabled
{
    self.isClickLoaderEnabled = enabled;
}

- (void)setClickBackgroundRedirection:(BOOL)enabled
{
    self.isClickBackgroundRedirectionEnabled = enabled;
}

#pragma mark private

- (NSString*)revenueModel {
    
    NSString *result = nil;
    PNAPIV3DataModel *data = [self metaDataWithType:@"revenuemodel"];
    if (data) {
        result = data.text;
    }
    return result;
}

- (NSString*)textAssetWithType:(NSString*)type
{
    NSString *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:type];
    if (data) {
        result = data.text;
    }
    return result;
}

- (NSString*)vastAssetWithType:(NSString*)type
{
    NSString *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:type];
    if (data) {
        result = data.vast;
    }
    return result;
}

- (NSNumber*)numberAssetWithType:(NSString*)type
{
    NSNumber *result = nil;
    PNAPIV3DataModel *data = [self assetDataWithType:type];
    if (data) {
        result = data.number;
    }
    return result;
}

- (PNAPIV3DataModel*)assetDataWithType:(NSString*)type
{
    PNAPIV3DataModel *result = nil;
    if (self.data) {
        result = [self.data assetWithType:type];
    }
    return result;
}

- (PNAPIV3DataModel*)metaDataWithType:(NSString*)type
{
    PNAPIV3DataModel *result = nil;
    if (self.data) {
        result = [self.data metaWithType:type];
    }
    return result;
}

# pragma confirm beacons

- (void)confirmBeaconsWithType:(NSString*)type
{
    if (self.data == nil || self.data.beacons == nil || self.data.beacons.count == 0) {
        NSLog(@"confirmBeaconsWithType: %@ - ad beacons not found", type);
    } else {
        for (PNAPIV3DataModel *beacon in self.data.beacons) {
            if ([beacon.type isEqualToString:type]) {
                NSString *beaconJs = [beacon stringFieldWithKey:@"js"];
                if (beacon.url && beacon.url.length > 0) {
                    NSURL *beaconUrl = [NSURL URLWithString:beacon.url];
                    NSURL *injectedUrl = [self injectExtrasWithUrl:beaconUrl];
                    [PNAPITrackingManager trackWithURL:injectedUrl];
                } else if (beaconJs && beaconJs.length > 0) {
                    __block NSString *beaconJsBlock = [beacon stringFieldWithKey:@"js"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIWebView *webView = [[UIWebView alloc] init];
                        webView.scalesPageToFit = YES;
                        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                        [webView stringByEvaluatingJavaScriptFromString:beaconJsBlock];
                    });
                }
            }
        }
    }
}

- (NSURL*)injectExtrasWithUrl:(NSURL*)url
{
    NSURL *result = url;
    if (self.trackingExtras != nil) {
        
        NSString *query = result.query;
        if(query == nil) {
            query = @"";
        }
        for (NSString *key in self.trackingExtras) {
            NSString *value = self.trackingExtras[key];
            query = [NSString stringWithFormat:@"%@&%@=%@", query, key, value];
        }
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        [urlComponents setQuery:query];
        result = urlComponents.URL;
    }
    return result;
}

#pragma mark Loader

- (void)showLoaderView
{
    if(self.loader == nil) {
    
        self.loader = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.loader.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f];
        
        UIActivityIndicatorView *activityLoader  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityLoader.hidesWhenStopped = true;
        [activityLoader startAnimating];
        activityLoader.center = self.loader.center;
        [self.loader addSubview:activityLoader];
        self.loader.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.loader addConstraint:[NSLayoutConstraint constraintWithItem:self.loader
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:activityLoader
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
        
        [self.loader addConstraint:[NSLayoutConstraint constraintWithItem:self.loader
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:activityLoader
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [[[window subviews] objectAtIndex:0] addSubview:self.loader];
}

- (void)hideLoaderView
{
    [self.loader removeFromSuperview];
    self.loader = nil;
}

#pragma mark Callback helpers

- (void)invokeImpressionConfirmedWithView:(UIView*)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(adModel:impressionConfirmedWithView:)]) {
            [self.delegate adModel:self impressionConfirmedWithView:view];
        }
    });
}

- (void)invokeClick
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(adModelDidClick:)]) {
            [self.delegate adModelDidClick:self];
        }
    });
}

#pragma mark
#pragma mark CALLBACKS
#pragma mark

#pragma mark PNAPIImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView*)view
{
    [self confirmBeaconsWithType:kPNAPIAdModelBeaconImpression];
    [self invokeImpressionConfirmedWithView:view];
}

#pragma mark PNAPIImpressionTrackerDelegate

- (void)clickCacherDidFinishWithURL:(NSString *)url
{
    self.clickRedirectionFinalURL = url;
    self.isPreparingClick = NO;
    
    if(self.isWaitingForClick) {
        
        self.isWaitingForClick = NO;
        [self openCachedClick];
        [self hideLoaderView];
    }
}

#pragma mark URDrillerDelegate

- (void)didStartWithURL:(NSURL *)url
{
    NSLog(@"URLDrill - didStartWithURL: %@", url);
    // Do nothing
}

- (void)didFinishWithURL:(NSURL *)url
{
    NSLog(@"URLDrill - didFinishWithURL: %@", url);
    
    [self hideLoaderView];
    
    if(!self.clickRedirectionFinalURL){
        NSString *urlString = [url absoluteString];
        [self openURLString:urlString];
    }
}

- (void)didRedirectWithURL:(NSURL *)url
{
    NSLog(@"URLDrill - didRedirectWithURL: %@", url);
}

- (void)didFailWithURL:(NSURL *)url andError:(NSError *)error
{
    NSLog(@"URLDrill - didFailWithURL: %@ - ERROR: %@", url, error);
    [self hideLoaderView];
    
    if(!self.clickRedirectionFinalURL){
        NSString *urlString = [url absoluteString];
        [self openURLString:urlString];
    }
}

@end
