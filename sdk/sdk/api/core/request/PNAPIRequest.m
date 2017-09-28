//
//  Copyright © 2016 PubNative. All rights reserved.
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

#import "PNAPIRequest.h"
#import "PNAPICryptoUtils.h"
#import "PNAPIHttpRequest.h"
#import "PNAPIRequestParameter.h"
#import "PNAPIAsset.h"
#import "PNAPIMeta.h"
#import "PNAPIV3ResponseModel.h"
#import "PNSettings.h"

NSString * const kPNAPIRequestBaseUrl = @"https://api.pubnative.net/api/v3/native";
NSString * const kPNResponseOk = @"ok";
NSString * const kPNResponseError = @"error";
NSInteger const kPNResponseStatusOK = 200;
NSInteger const kPNResponseStatusRequestMalformed = 422;

@interface PNAPIRequest () <PNAPIHttpRequestDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak)NSObject <PNAPIRequestDelegate>  *delegate;
@property (nonatomic, assign)BOOL                           isRunning;
@property (nonatomic, strong)NSMutableDictionary            *requestParameters;

@end

@implementation PNAPIRequest

#pragma mark
#pragma mark NSObject
#pragma mark

- (void)dealloc
{
    self.requestParameters = nil;
}

#pragma mark
#pragma mark PNAPIRequest
#pragma mark
#pragma mark public

- (void)startWithDelegate:(NSObject<PNAPIRequestDelegate> *)delegate
{
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"request is currently running, droping this call" code:0 userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(delegate == nil){
        NSLog(@"given delegate is nil and required, droping this call");
    } else {
        self.delegate = delegate;
        self.isRunning = YES;
        [self invokeDidStart];
        [self fillDefaultParameters];
        
        NSURL *url = [self requestURL];
        [[PNAPIHttpRequest alloc] startWithUrlString:url.absoluteString
                                         delegate:self];
    }
}

- (void)addParameterWithKey:(NSString*)key value:(NSString*)value
{
    if(key
       && key.length > 0
       && value
       && value.length > 0) {
        
        if (self.requestParameters == nil) {
            self.requestParameters = [NSMutableDictionary dictionary];
        }
        self.requestParameters[key] = value;
    }
}

- (void)addParameterArrayWithKey:(NSString *)key array:(NSArray<NSString *> *)array
{
    if(key
       && key.length > 0
       && array
       && array.count > 0) {
        
        NSString *value = [array componentsJoinedByString:@","];
        [self addParameterWithKey:key value:value];
    }
}

- (void)setParameterWithKey:(NSString*)key enabled:(BOOL)enabled
{
    [self addParameterWithKey:key value:enabled?@"1":@"0"];
}

#pragma mark PNAPIRequestModes

- (void)setTestMode:(BOOL)enabled
{
    [self setParameterWithKey:PNAPIRequestParameter.test enabled:enabled];
}

- (void)setCoppaMode:(BOOL)enabled
{
    [self setParameterWithKey:PNAPIRequestParameter.coppa enabled:enabled];
}

#pragma mark private

- (void)fillDefaultParameters
{
    if (self.requestParameters == nil) {
        self.requestParameters = [NSMutableDictionary dictionary];
    }
    
    self.requestParameters[PNAPIRequestParameter.os] = [PNSettings sharedInstance].os;
    self.requestParameters[PNAPIRequestParameter.osVersion] = [PNSettings sharedInstance].osVersion;
    self.requestParameters[PNAPIRequestParameter.deviceModel] = [PNSettings sharedInstance].deviceName;
    self.requestParameters[PNAPIRequestParameter.locale] = [PNSettings sharedInstance].locale;
    [self setIDFA];
    [self setLocation];
    [self setDefaultAssetFields];
    [self setDefaultMetaFields];
    
}

- (void)setIDFA {
    
    NSString *advertisingId = [PNSettings sharedInstance].advertisingId;
    if (advertisingId == nil || advertisingId.length == 0) {
        self.requestParameters[PNAPIRequestParameter.dnt] = @"1";
    } else {
        self.requestParameters[PNAPIRequestParameter.idfa] = advertisingId;
        self.requestParameters[PNAPIRequestParameter.idfamd5] = [PNAPICryptoUtils md5WithString:advertisingId];
        self.requestParameters[PNAPIRequestParameter.idfasha1] = [PNAPICryptoUtils sha1WithString:advertisingId];
    }
}

- (void)setLocation
{
    CLLocation *location = [PNSettings sharedInstance].location;
    if (location) {
        self.requestParameters[PNAPIRequestParameter.lon] = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        self.requestParameters[PNAPIRequestParameter.lat] = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    }
}

- (void)setDefaultAssetFields
{
    if (self.requestParameters[PNAPIRequestParameter.assetsField] == nil
        && self.requestParameters[PNAPIRequestParameter.assetLayout] == nil) {
        
        NSArray *assets = @[PNAPIAsset.title,
                            PNAPIAsset.description,
                            PNAPIAsset.icon,
                            PNAPIAsset.banner,
                            PNAPIAsset.cta,
                            PNAPIAsset.rating];
        
        self.requestParameters[PNAPIRequestParameter.assetsField] = [assets componentsJoinedByString:@","];
    }
}

- (void)setDefaultMetaFields
{
    NSString *metaFieldsString = self.requestParameters[PNAPIRequestParameter.metaField];
    NSMutableArray *newMetaFields = [NSMutableArray array];
    if (metaFieldsString && metaFieldsString.length > 0) {
        newMetaFields = [[metaFieldsString componentsSeparatedByString:@","] mutableCopy];
    }
    if (![newMetaFields containsObject:PNAPIMeta.revenueModel]) {
        [newMetaFields addObject:PNAPIMeta.revenueModel];
    }
    if (![newMetaFields containsObject:PNAPIMeta.contentInfo]) {
        [newMetaFields addObject:PNAPIMeta.contentInfo];
    }
    self.requestParameters[PNAPIRequestParameter.metaField] = [newMetaFields componentsJoinedByString:@","];
}

- (NSURL*)requestURL
{
    NSURLComponents *components = [NSURLComponents componentsWithString:kPNAPIRequestBaseUrl];
    if (self.requestParameters) {
        NSMutableArray *query = [NSMutableArray array];
        NSDictionary *dict = self.requestParameters;
        for (id key in dict) {
            [query addObject:[NSURLQueryItem queryItemWithName:key value:dict[key]]];
        }
        components.queryItems = query;
    }
    return components.URL;
}

#pragma mark Callback helpers

- (void)invokeDidStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
            [self.delegate requestDidStart:self];
        }
    });
}

- (void)invokeDidLoad:(NSArray*)ads
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRunning = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoad:)]) {
            [self.delegate request:self didLoad:ads];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRunning = NO;
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFail:)]){
            [self.delegate request:self didFail:error];
        }
        self.delegate = nil;
    });
}

#pragma mark - CALLBACKS - 
#pragma mark PNAPIHttpRequestDelegate

- (void)request:(PNAPIHttpRequest *)request didFailWithError:(NSError *)error
{
    [self invokeDidFail:error];
}

- (void)request:(PNAPIHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode
{
    if(kPNResponseStatusOK == statusCode
       || kPNResponseStatusRequestMalformed == statusCode) {
        
        [self processResponseWithData:data];
    } else {
        
        NSError *statusError = [NSError errorWithDomain:@"Server error: status code" code:statusCode userInfo:nil];
        [self invokeDidFail:statusError];
    }
}

- (void)processResponseWithData:(NSData*)data
{
    NSError *parseError;
    NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&parseError];
    if (parseError) {
        
        [self invokeDidFail:parseError];
        
    } else {
        
        PNAPIV3ResponseModel *apiResponse = [[PNAPIV3ResponseModel alloc] initWithDictionary:jsonDictonary];
        
        if(apiResponse == nil) {
            
            NSError *error = [NSError errorWithDomain:@"Error: Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else if ([kPNResponseOk isEqualToString:apiResponse.status]) {
            
            NSMutableArray *ads = [[NSArray array] mutableCopy];
            for (PNAPIV3AdModel *ad in apiResponse.ads) {
                PNAPIAdModel *model = [[PNAPIAdModel alloc] initWithData:ad];
                if(model) {
                    [ads addObject:model];
                }
            }
            if (ads.count > 0) {
                [self invokeDidLoad:ads];
            } else {
                NSError *error = [NSError errorWithDomain:@"Error: No fill"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        } else {
            
            NSString *errorMessage = [NSString stringWithFormat:@"request - %@", apiResponse.errorMessage];
            NSError *responseError = [NSError errorWithDomain:errorMessage
                                                         code:0
                                                     userInfo:nil];
            [self invokeDidFail:responseError];
        }   
    }
}

@end
