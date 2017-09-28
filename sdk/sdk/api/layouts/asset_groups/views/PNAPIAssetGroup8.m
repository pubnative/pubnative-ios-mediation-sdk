//
//  PNAPIAssetGroup8.m
//  sdk
//
//  Created by David Martin on 10/06/2017.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import "PNAPIAssetGroup8.h"

@interface PNAPIAssetGroup8 () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PNAPIAssetGroup8

- (void)load
{
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = false;
    [self.webView loadHTMLString:self.model.htmlUrl baseURL:nil];
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

#pragma mark - CALLBACKS -
#pragma mark UIWebViewlDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return true;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self invokeLoadFinish];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self invokeLoadFail:error];
}

@end
