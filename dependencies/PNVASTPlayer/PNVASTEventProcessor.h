//
//  Copyright (c) 2017 PubNative
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PNVASTModel.h"

typedef enum : NSInteger {
    PNVASTEvent_Start,
    PNVASTEvent_FirstQuartile,
    PNVASTEvent_Midpoint,
    PNVASTEvent_ThirdQuartile,
    PNVASTEvent_Complete,
    PNVASTEvent_Close,
    PNVASTEvent_Pause,
    PNVASTEvent_Resume,
    PNVASTEvent_Unknown
} PNVASTEvent;

@class PNVASTEventProcessor;

@protocol PNVASTEventProcessorDelegate <NSObject>

- (void)eventProcessorDidTrackEvent:(PNVASTEvent)event;

@end

@interface PNVASTEventProcessor : NSObject

// designated initializer, uses tracking events stored in VASTModel
- (id)initWithEvents:(NSDictionary *)events delegate:(id<PNVASTEventProcessorDelegate>)delegate;
// sends the given VASTEvent
- (void)trackEvent:(PNVASTEvent)event;
// sends the set of http requests to supplied URLs, used for Impressions, ClickTracking, and Errors.
- (void)sendVASTUrls:(NSArray *)url;

@end
