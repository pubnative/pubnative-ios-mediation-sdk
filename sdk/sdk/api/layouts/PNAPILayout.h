

#import <Foundation/Foundation.h>
#import "PNAPIRequest.h"
#import "PNAPIAdModel.h"
#import "PNAPILayoutViewController.h"

@class PNAPILayout;

typedef enum : NSUInteger {
    SMALL,
    MEDIUM,
    LARGE,
} PNAPILayoutSize;

@protocol PNAPILayoutLoadDelegate <NSObject>

- (void)layout:(PNAPILayout *)layout loadDidFinish:(PNAPIAdModel *)model;
- (void)layout:(PNAPILayout*)layout loadDidFail:(NSError*)error;

@end

@protocol PNAPILayoutFetchDelegate <NSObject>

- (void)layout:(PNAPILayout*)layout fetchDidFinish:(PNAPILayoutViewController*)viewController;
- (void)layout:(PNAPILayout*)layout fetchDidFail:(NSError*)error;

@end

@interface PNAPILayout: PNAPIRequest

@property(nonatomic, strong)PNAPIAdModel *model;

- (void)loadWithSize:(PNAPILayoutSize)size loadDelegate:(NSObject<PNAPILayoutLoadDelegate>*)loadDelegate;
- (void)fetchWithDelegate:(NSObject<PNAPILayoutFetchDelegate>*)fetchDelegate;

@end
