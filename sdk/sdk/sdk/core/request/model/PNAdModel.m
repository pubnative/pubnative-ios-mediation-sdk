//
//  PNAdModel.m
//  sdk
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PNAdModel+Fetching.h"
#import "PNAdModel+Internal.h"

@interface PNAdModel ()

@property (nonatomic, assign) BOOL                  isImpressionTracked;
@property (nonatomic, assign) BOOL                  isClickTracked;
@property (nonatomic, assign) NSInteger             remainingCacheableAssets;
@property (nonatomic, strong) NSMutableDictionary   *cachedAssets;
@property (nonatomic, strong) PNInsightModel        *insightModel;

@property (nonatomic, strong) UIImageView           *bannerImageView;

@property (nonatomic, weak) NSObject<PNAdModelFetchDelegate> *fetchDelegate;

@end

@implementation PNAdModel

- (void)dealloc
{
    self.insightModel = nil;
    self.cachedAssets = nil;
}

- (NSString*)title
{
    NSLog(@"PNAdModel - Error: override me");
    return nil;
}

- (NSString*)description
{
    NSLog(@"PNAdModel - Error: override me");
    return nil;
}

- (UIImage*)icon
{
    UIImage *result = nil;
    NSString *iconURLString = [self iconURLString];
    if(iconURLString && iconURLString.length > 0) {
        NSURL *iconURL = [NSURL URLWithString:iconURLString];
        NSData *imageData = self.cachedAssets[iconURL];
        if(imageData && imageData.length > 0) {
            result = [UIImage imageWithData:imageData];
        }
    }
    return result;
}

- (UIView*)banner
{
    if (self.bannerImageView == nil) {
        NSString *bannerURLString = [self bannerURLString];
        if(bannerURLString && bannerURLString.length > 0) {
            NSURL *bannerURL = [NSURL URLWithString:bannerURLString];
            NSData *bannerData = self.cachedAssets[bannerURL];
            if(bannerData && bannerData.length > 0) {
                UIImage *bannerImage = [UIImage imageWithData:bannerData];
                if(bannerImage) {
                    self.bannerImageView = [[UIImageView alloc] initWithImage:bannerImage];
                    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
                }
            }
        }
    }
    return self.bannerImageView;
}

- (NSString*)callToAction
{
    NSLog(@"PNAdModel - Error: override me");
    return nil;
}

- (NSNumber*)starRating
{
    NSLog(@"PNAdModel - Error: override me");
    return @0;
}

- (UIView*)contentInfo
{
    NSLog(@"PNAdModel - Error: override me");
    return nil;
}

- (NSString*)iconURLString
{
    NSLog(@"PNAdModel - Error: override me");
    return nil;
}

- (NSString*)bannerURLString
{
    NSLog(@"PNAdModel - Error: override me");
    return nil;
}

- (void)startTrackingView:(UIView*)view
       withViewController:(UIViewController*)viewController
{
    NSLog(@"PNAdModel - Error: override me");
}

- (void)stopTracking
{
    NSLog(@"PNAdModel - Error: override me");
}

- (void)fetchAssetsWithDelegate:(NSObject<PNAdModelFetchDelegate>*)delegate
{
    NSMutableArray *assets = [NSMutableArray array];
    if ([self bannerURLString]) [assets addObject:[self bannerURLString]];
    if ([self iconURLString]) [assets addObject:[self iconURLString]];
    
    if (delegate) {
        [self fetchAssets:assets];
    } else {
        NSLog(@"PNAdModel - Error: Fetch asssets with delegate nil, dropping this call");
    }
}

- (void)fetchAssets:(NSArray<NSString*>*)assets
{
    if(assets && assets.count > 0) {
        self.remainingCacheableAssets = assets.count;
        for (NSString *assetURLString in assets) {
            [self fetchAsset:assetURLString];
        }
        
    } else {
        [self invokeFetchDidFailWithError:[NSError errorWithDomain:@"no assets to fetch" code:0 userInfo:nil]];
    }
}

- (void)fetchAsset:(NSString*)assetURLString
{
    if (assetURLString && assetURLString.length > 0) {
        __block NSURL *url = [NSURL URLWithString:assetURLString];
        __block PNAdModel *strongSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                [strongSelf cacheAssetWithURL:url data:data];
                [strongSelf checkFetchProgress];
            } else {
                [strongSelf invokeFetchDidFailWithError:[NSError errorWithDomain:@"Asset can not be downloaded."
                                                                            code:0
                                                                        userInfo:nil]];
            }
            url = nil;
            strongSelf = nil;
        });
    } else {
        [self invokeFetchDidFailWithError:[NSError errorWithDomain:@"asset URL is nil or empty"
                                                              code:0
                                                          userInfo:nil]];
    }
}

- (void)checkFetchProgress
{
    self.remainingCacheableAssets --;
    if (self.remainingCacheableAssets == 0) {
        [self invokeFetchDidFinish];
    }
}

- (void)cacheAssetWithURL:(NSURL*)url data:(NSData *)data
{
    if (self.cachedAssets == nil) {
        self.cachedAssets = [NSMutableDictionary dictionary];
    }
    
    if (url && data) {
        self.cachedAssets[url] = data;
    }
}

#pragma mark -Native interface-

- (void)setInsight:(PNInsightModel*)model
{
    self.insightModel = model;
}

#pragma mark -View helpers-

- (void)renderAd:(PNAdModelRenderer*)renderer
{
    if(renderer.titleView) {
        renderer.titleView.text = self.title;
    }
    
    if(renderer.descriptionView) {
        renderer.descriptionView.text = self.description;
    }
    
    if(renderer.callToActionView) {
        if ([renderer.callToActionView isKindOfClass:[UIButton class]]) {
            [(UIButton *) renderer.callToActionView setTitle:self.callToAction forState:UIControlStateNormal];
        } else if ([renderer.callToActionView isKindOfClass:[UILabel class]]) {
            [(UILabel *) renderer.callToActionView setText:self.callToAction];
        }
    }
    
    if (renderer.starRatingView) {
        renderer.starRatingView.value = [self.starRating floatValue];
    }
    
    UIImage *icon = self.icon;
    if(renderer.iconView && icon) {
        renderer.iconView.image = icon;
    }
    
    UIView *banner = self.banner;
    if(renderer.bannerView && banner) {
        [renderer.bannerView addSubview:banner];
        banner.frame = renderer.bannerView.bounds;
    }
    
    UIView *contentInfo = self.contentInfo;
    if (renderer.contentInfoView && contentInfo) {
        [renderer.contentInfoView addSubview:contentInfo];
        contentInfo.frame = renderer.contentInfoView.bounds;
    }
}

#pragma mark -Helpers-

- (void)invokeDidConfirmImpression
{
    if(!self.isImpressionTracked) {
        
        self.isImpressionTracked = YES;
        [self.insightModel sendImpressionInsight];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pubantiveAdDidConfirmImpression:)]){
            [self.delegate pubantiveAdDidConfirmImpression:self];
        }
    }
}

- (void)invokeDidClick
{
    if(!self.isClickTracked){
        
        self.isClickTracked = YES;
        [self.insightModel sendClickInsight];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeAdDidClick:)]){
        [self.delegate pubnativeAdDidClick:self];
    }
}

- (void)invokeFetchDidFinish
{
    __block NSObject<PNAdModelFetchDelegate> *delegate = self.fetchDelegate;
    __block PNAdModel *strongSelf = self;
    self.fetchDelegate = nil;
    if (delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(pubnativeAdFetchDidFinish:)]) {
                [delegate pubnativeAdFetchDidFinish:strongSelf];
            }
            delegate = nil;
            strongSelf = nil;
        });
    }
}

- (void)invokeFetchDidFailWithError:(NSError *)error
{
    __block NSError *blockError = error;
    __block PNAdModel *strongSelf = self;
    __block NSObject<PNAdModelFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    if (delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(pubnativeAdFetchDidFinish:)]) {
                [delegate pubnativeAdFetchDidFail:strongSelf withError:blockError];
            }
            delegate = nil;
            blockError = nil;
            strongSelf = nil;
        });
    }
}

@end
