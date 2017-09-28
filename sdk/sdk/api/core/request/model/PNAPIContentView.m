//
//  PNAPIContentView.m
//  library
//
//  Created by David Martin on 26/10/2016.
//  Copyright © 2016 PubNative. All rights reserved.
//

#import "PNAPIContentView.h"
#import "PNAPIMeta.h"

CGFloat const kPNAPIContentViewHeight = 20.0f;
CGFloat const kPNAPIContentViewWidth = 20.0f;
NSTimeInterval const kPNAPIContentViewClosingTime = 3.0f;

@interface PNAPIContentView ()

@property (nonatomic, strong)UILabel            *textView;
@property (nonatomic, strong)UIImageView        *iconView;
@property (nonatomic, strong)UIImage            *iconImage;
@property (nonatomic, assign)BOOL               isOpen;
@property (nonatomic, assign)CGFloat            openSize;
@property (nonatomic, strong)NSTimer            *closeTimer;
@property (nonatomic, strong)NSLayoutConstraint *widthConstraint;

@end

@implementation PNAPIContentView

- (void)dealloc
{
    [self.closeTimer invalidate];
    self.closeTimer = nil;
    [self.textView removeFromSuperview];
    self.textView = nil;
    [self.iconView removeFromSuperview];
    self.iconView = nil;
    self.iconImage = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:.75f];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2.f;
        
        self.isOpen = NO;
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.f
                                                             constant:kPNAPIContentViewWidth];
        
        self.textView = [[UILabel alloc] init];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.iconView];
        [self addSubview:self.textView];
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNAPIContentViewHeight],
                               self.widthConstraint,
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNAPIContentViewHeight],
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNAPIContentViewWidth],
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNAPIContentViewHeight],
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.iconView
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f]]];
    }
    return self;
}

- (void)layoutSubviews
{
    self.hidden = YES;
    
    if(self.iconImage == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.icon]];
            self.iconImage = [UIImage imageWithData:iconData];
            [self configureView];
        });
    } else {
        [self configureView];
    }
}

- (void)configureView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = self.text;
        [self.textView sizeToFit];
        [self.iconView setImage:self.iconImage];
        self.openSize = self.iconView.frame.size.width+self.textView.frame.size.width;
        self.hidden = NO;
    });
}

- (void)stopCloseTimer
{
    [self.closeTimer invalidate];
    self.closeTimer = nil;
}

- (void)startCloseTimer
{
    self.closeTimer = [NSTimer scheduledTimerWithTimeInterval:kPNAPIContentViewClosingTime
                                                      repeats:NO
                                                        block:^(NSTimer * _Nonnull timer) {
                                                                   if([timer isValid]) {
                                                                       [self close];
                                                                   }
                                                               }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.isOpen) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
        [self close];
    } else {
        [self open];
    }
}

- (void)open
{
    self.isOpen = YES;
    [self layoutIfNeeded];
    self.widthConstraint.constant = self.openSize;
    [self layoutIfNeeded];
    [self startCloseTimer];
}

- (void)close
{
    self.isOpen = NO;
    [self stopCloseTimer];
    [self layoutIfNeeded];
    self.widthConstraint.constant = kPNAPIContentViewWidth;
    [self layoutIfNeeded];
}

@end
