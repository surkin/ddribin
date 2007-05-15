//
//  DDMultipartInputStream.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMultipartInputStream.h"
#import "DDExtensions.h"

@interface DDMultipartInputStream (Private)

- (void) buildBody;

@end

@implementation DDMultipartInputStream

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mBoundary = @"1174583781";
    mParts = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSString *) boundary;
{
    return mBoundary;
}

- (void) addPartWithName: (NSString *) name data: (NSData *) data;
{
    DDMultipartDataPart * part = [DDMultipartDataPart partWithName: name
                                                       dataContent: data];
    [mParts addObject: part];
}

- (void) addPartWithName: (NSString *) name string: (NSString *) string;
{
    NSData * data = [string dataUsingEncoding: NSUTF8StringEncoding];
    [self addPartWithName: name data: data];
}

- (void) addPartWithName: (NSString *) name intValue: (int) intValue;
{
    NSString * intString = [NSString stringWithFormat: @"%d", intValue];
    [self addPartWithName: name string: intString];
}

- (void) addPartWithName: (NSString *) name fileAtPath: (NSString *) path;
{
    DDMultipartDataPart * part = [DDMultipartDataPart partWithName: name
                                                       fileContent: path];
    [mParts addObject: part];
}

#pragma mark -
#pragma mark NSInputStream Overrides

- (void) open
{
    [self buildBody];
    [mBodyStream open];
}

- (void) close
{
    [mBodyStream close];
}

- (int) read: (uint8_t *) buffer maxLength: (unsigned int) len;
{
    return [mBodyStream read: buffer maxLength: len];
}

@end

@implementation DDMultipartInputStream (Private)

- (void) buildBody;
{
    NSMutableData * body = [NSMutableData data];
    NSString * firstDelimiter = [NSString stringWithFormat: @"--%@\r\n", mBoundary];
    NSString * middleDelimiter = [NSString stringWithFormat: @"\r\n--%@\r\n", mBoundary];
    NSString * finalDelimiter = [NSString stringWithFormat: @"\r\n--%@--\r\n", mBoundary];
    NSString * delimiter = firstDelimiter;
    
    NSEnumerator * e = [mParts objectEnumerator];
    DDMultipartDataPart * part;
    while (part = [e nextObject])
    {
        [body dd_appendUTF8Format: delimiter];
        [body dd_appendUTF8String: [part headersAsString]];
        [body appendData: [part contentAsData]];
        
        delimiter = middleDelimiter;
    }
    [body dd_appendUTF8Format: finalDelimiter];
    
    mBodyStream = [[NSInputStream alloc] initWithData: body];
}

@end

@implementation DDMultipartDataPart

+ partWithName: (NSString *) name dataContent: (NSData *) data;
{
    return [[[self alloc] initWithName: name dataContent: data] autorelease];
}

+ partWithName: (NSString *) name fileContent: (NSString *) path;
{
    return [[[self alloc] initWithName: name fileContent: path] autorelease];
}

- (id) initWithName: (NSString *) name dataContent: (NSData *) data;
{
    NSString * headers = [NSString stringWithFormat:
        @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
        name];
    return [self initWithHeaders: headers dataContent: data];
}

- (id) initWithName: (NSString *) name fileContent: (NSString *) path;
{
    NSMutableString * headers = [NSMutableString string];
    [headers appendFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
            name, [path lastPathComponent]];
    [headers appendString: @"Content-Transfer-Encoding: binary\r\n"];
    [headers appendFormat: @"Content-Type: %@\r\n", [path dd_mimeTypeOfPath]];
    [headers appendString: @"\r\n"];
    return [self initWithHeaders: headers dataContent: [NSData dataWithContentsOfFile: path]];
}

- (id) initWithHeaders: (NSString *) headers dataContent: (NSData *) data;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHeaders = [headers retain];
    mContentData = [data retain];
    
    return self;
}

- (NSString *) headersAsString;
{
    return mHeaders;
}

- (NSData *) contentAsData;
{
    return mContentData;
}

@end
