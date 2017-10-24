//
//  PNAPIContentView.m
//  library
//
//  Created by David Martin on 26/10/2016.
//  Copyright © 2016 PubNative. All rights reserved.
//

#import "PNAPIContentView.h"
#import "PNAPIMeta.h"
#import "PNOrientationManager.h"

NSString * const kPNAPIContentViewSizeChanged = @"kPNAPIContentViewSizeChanged";
CGFloat const kPNAPIContentViewHeight = 15.0f;
CGFloat const kPNAPIContentViewWidth = 15.0f;
NSTimeInterval const kPNAPIContentViewClosingTime = 3.0f;

@interface PNAPIContentView ()

@property (nonatomic, strong)UILabel            *textView;
@property (nonatomic, strong)UIImageView        *iconView;
@property (nonatomic, strong)UIImage            *iconImage;
@property (nonatomic, assign)BOOL               isOpen;
@property (nonatomic, assign)CGFloat            openSize;
@property (nonatomic, strong)NSTimer            *closeTimer;
@property (nonatomic, strong)UITapGestureRecognizer         *tapRecognizer;

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
    
    [self.tapRecognizer removeTarget:self action:@selector(handleTap:)];
    [self removeGestureRecognizer:self.tapRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tapRecognizer = nil;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, kPNAPIContentViewWidth, kPNAPIContentViewHeight)];
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2.f;
        
        self.isOpen = NO;
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:self.tapRecognizer];
        self.textView = [[UILabel alloc] init];
        [self.textView setFont:[self.textView.font fontWithSize:10]];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.iconView];
        [self addSubview:self.textView];
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.iconView
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotateNotification:)
                                                     name:kPNOrientationManagerDidChangeOrientation
                                                   object:nil];
    }
    return self;
}

- (void)didRotateNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPNAPIContentViewSizeChanged
                                                        object:[NSNumber numberWithFloat: self.frame.size.width]];
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
    self.closeTimer = [NSTimer scheduledTimerWithTimeInterval:kPNAPIContentViewClosingTime target:self selector:@selector(closeFromTimer) userInfo:nil repeats:NO];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if(self.isOpen) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
            [self close];
        } else {
            [self open];
        }
    }
}

- (void)open
{
    self.isOpen = YES;
    [self layoutIfNeeded];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.openSize, self.frame.size.height);
    [self layoutIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPNAPIContentViewSizeChanged
                                                        object:[NSNumber numberWithFloat: self.frame.size.width]];
    [self startCloseTimer];
}

-(void)closeFromTimer
{
    if ([self.closeTimer isValid]) {
        [self close];
    }
}

- (void)close
{
    self.isOpen = NO;
    [self stopCloseTimer];
    [self layoutIfNeeded];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kPNAPIContentViewWidth, self.frame.size.height);
    [self layoutIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPNAPIContentViewSizeChanged
                                                        object:[NSNumber numberWithFloat: self.frame.size.width]];
}

@end
