//
//  PNAPIAssetGroup9.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup9.h"

@interface PNAPIAssetGroup9 ()

@property (weak, nonatomic) IBOutlet UIImageView *banner;

@end

@implementation PNAPIAssetGroup9

- (void)load
{
    __block NSURL *bannerURL = [NSURL URLWithString:self.model.standardBannerUrl];
    __block PNAPIAssetGroup9 *strongSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSData *bannerData = [NSData dataWithContentsOfURL:bannerURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bannerData == nil) {
                [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get data"
                                                               code:0
                                                           userInfo:nil]];
            } else {
                UIImage *bannerImage = [UIImage imageWithData:bannerData];
                if(bannerImage == nil) {
                    [strongSelf invokeLoadFail:[NSError errorWithDomain:@"Error: cannot get image"
                                                                   code:0
                                                               userInfo:nil]];
                } else {
                    strongSelf.banner.image = bannerImage;
                    [strongSelf invokeLoadFinish];
                }
            }
            bannerURL = nil;
            strongSelf = nil;
            bannerData = nil;
        });
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

@end
