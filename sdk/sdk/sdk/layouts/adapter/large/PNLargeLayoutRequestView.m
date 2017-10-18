//
//  PNLargeLayoutRequestView.m
//  sdk
//
//  Created by Can Soykarafakili on 05.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNLargeLayoutRequestView.h"

@interface PNLargeLayoutRequestView ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *descriptionLabel;
@property (nonatomic, weak) UIImageView *icon;
@property (nonatomic, weak) UIButton *callToAction;

@property (nonatomic, weak) UILabel *socialContext;
@property (nonatomic, weak) UIView *contentInfoView;


@end

@implementation PNLargeLayoutRequestView

- (void)loadWithAd:(PNAdModel *)nativeAd
{
    
    PNAdModelRenderer *renderer = [[PNAdModelRenderer alloc] init];
    renderer.titleView = self.titleLabel;
    renderer.iconView = self.icon;
    renderer.descriptionView = self.descriptionLabel;
    renderer.callToActionView = self.callToAction;
    
    [nativeAd renderAd:renderer];
}

@end
