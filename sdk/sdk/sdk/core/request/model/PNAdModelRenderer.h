//
//  PNAdModelRenderer.h
//  sdk
//
//  Created by Can Soykarafakili on 31.07.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNStarRatingView.h"

@interface PNAdModelRenderer : NSObject

@property (nonatomic, weak) UILabel *titleView;
@property (nonatomic, weak) UILabel *descriptionView;
@property (nonatomic, weak) UIView *callToActionView;
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UIView *bannerView;
@property (nonatomic, weak) PNStarRatingView *starRatingView;
@property (nonatomic, weak) UIView *contentInfoView;

@end
