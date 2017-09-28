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

#import "PNVASTParser.h"
#import "PNVASTXMLUtil.h"
#import "PNVASTModel.h"
#import "PNVASTSchema.h"

NSInteger const kPNVASTModel_MaxRecursiveDepth = 5;
BOOL const kPNVASTModel_ValidateWithSchema = NO;

@interface PNVASTModel (private)

- (void)addVASTDocument:(NSData *)vastDocument;

@end

@interface PNVASTParser ()

@property (nonatomic, strong) PNVASTModel *vastModel;

- (PNVASTParserError)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth;

@end

@implementation PNVASTParser

- (id)init
{
    self = [super init];
    if (self) {
        self.vastModel = [[PNVASTModel alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.vastModel = nil;
}

#pragma mark - "public" methods

- (void)parseWithUrl:(NSURL *)url completion:(vastParserCompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *vastData = [NSData dataWithContentsOfURL:url];
        PNVASTParserError vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

- (void)parseWithData:(NSData *)vastData completion:(vastParserCompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PNVASTParserError vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

#pragma mark - "private" method

- (PNVASTParserError)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth
{
    if (depth >= kPNVASTModel_MaxRecursiveDepth) {
        self.vastModel = nil;
        return PNVASTParserError_TooManyWrappers;
    }
    
    // sanity check
    __unused NSString *content = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];

    // Validate the basic XML syntax of the VAST document.
    BOOL isValid;
    isValid = validateXMLDocSyntax(vastData);
    if (!isValid) {
        self.vastModel = nil;
        return PNVASTParserError_XMLParse;
    }

    if (kPNVASTModel_ValidateWithSchema) {
        
        // Using header data
        NSData *PNVASTSchemaData = [NSData dataWithBytesNoCopy:pubnative_vast_2_0_1_xsd
                                                      length:pubnative_vast_2_0_1_xsd_len
                                                freeWhenDone:NO];
        isValid = validateXMLDocAgainstSchema(vastData, PNVASTSchemaData);
        if (!isValid) {
            self.vastModel = nil;
            return PNVASTParserError_SchemaValidation;
        }
    }

    [self.vastModel addVASTDocument:vastData];
    
    // Check to see whether this is a wrapper ad. If so, process it.
    NSString *query = @"//VASTAdTagURI";
    NSArray *results = performXMLXPathQuery(vastData, query);
    if ([results count] > 0) {
        NSString *url;
        NSDictionary *node = results[0];
        if ([node[@"nodeContent"] length] > 0) {
            // this is for string data
            url =  node[@"nodeContent"];
        } else {
            // this is for CDATA
            NSArray *childArray = node[@"nodeChildArray"];
            if ([childArray count] > 0) {
                // we assume that there's only one element in the array
                url = ((NSDictionary *)childArray[0])[@"nodeContent"];
            }
        }
        vastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        return [self parseRecursivelyWithData:vastData depth:(depth + 1)];
    }
    
    return PNVASTParserError_None;
}

- (NSString *)content:(NSDictionary *)node
{
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }
    
    // this is for CDATA
    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // we assume that there's only one element in the array
        return ((NSDictionary *)childArray[0])[@"nodeContent"];
    }
    
    return nil;
}

@end
