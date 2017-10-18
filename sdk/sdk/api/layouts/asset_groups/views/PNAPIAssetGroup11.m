//
//  PNAPIAssetGroup11.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup11.h"

@interface PNAPIAssetGroup11 ()

@property (weak, nonatomic) IBOutlet UIImageView *banner;
@property (weak, nonatomic) IBOutlet UIView *contentInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@end

@implementation PNAPIAssetGroup11

- (void)load
{
    [self.contentInfoView addSubview:self.model.contentInfo];
    __block NSURL *bannerURL = [NSURL URLWithString:self.model.bannerUrl];
    __block PNAPIAssetGroup11 *strongSelf = self;
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

- (void)updateContentInfoSize:(NSNotification *)notification
{
    NSNumber *contentInfoSize = notification.object;
    self.widthConstraint.constant = [contentInfoSize floatValue];
    [self.view layoutIfNeeded];
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
