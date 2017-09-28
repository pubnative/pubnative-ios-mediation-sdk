//
//  PNAdTargetingModel.h
//  sdk
//
//  Created by Alvarlega on 28/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kPNAdTargetingModelGenderFemale;
extern NSString* const kPNAdTargetingModelGenderMale;

@interface PNAdTargetingModel : NSObject

@property (nonatomic, strong) NSNumber              *age;
@property (nonatomic, strong) NSString              *education;
@property (nonatomic, strong) NSArray<NSString*>    *interests;
@property (nonatomic, assign) NSString              *gender; // `f` for female or `m` for male
@property (nonatomic, strong) NSNumber              *iap; // In app purchase enabled, Just open it for the user to fill
@property (nonatomic, strong) NSNumber              *iap_total; // In app purchase total spent, just open for the user to fill

- (NSDictionary*)toDictionary;
- (NSDictionary*)toDictionaryWithIAP;

@end
