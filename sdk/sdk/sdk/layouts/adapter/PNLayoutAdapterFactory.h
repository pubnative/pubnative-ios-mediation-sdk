//
//  PNLayoutAdapterFactory.h
//  sdk
//
//  Created by Can Soykarafakili on 19.06.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNLayoutAdapter.h"

@interface PNLayoutAdapterFactory : NSObject

@property (nonatomic, readonly) NSString *factoryName;

- (PNLayoutAdapter*)adapterWithName:(NSString*)name;
+ (instancetype)sharedFactory;

@end
