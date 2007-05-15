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
    mPartStreams = [[NSMutableArray alloc] init];
    
    return self;
}

/*
    [self close];
 */

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [self close];
    [mBoundary release];
    [mParts release];
    [mPartStreams release];
    
    mBoundary = nil;
    mParts = nil;
    mPartStreams = nil;
    [super dealloc];
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
    [mPartStreams makeObjectsPerformSelector: @selector(open)];
    mCurrentStream = nil;
    mStreamIndex = 0;
    if ([mPartStreams count] > 0)
        mCurrentStream = [mPartStreams objectAtIndex: mStreamIndex];
}

- (void) close
{
    [mPartStreams makeObjectsPerformSelector: @selector(close)];
}

- (BOOL) hasBytesAvailable;
{
    return (mCurrentStream != nil);
}

- (int) read: (uint8_t *) buffer maxLength: (unsigned int) len;
{
    if (mCurrentStream == nil)
        return 0;
    
    int result = [mCurrentStream read: buffer maxLength: len];
    if ((result == 0) &&  (mStreamIndex < [mPartStreams count] - 1))
    {
        mStreamIndex++;
        mCurrentStream = [mPartStreams objectAtIndex: mStreamIndex];
        result = [self read: buffer maxLength: len];
    }
    
    if (result == 0)
        mCurrentStream == nil;
        
    return result;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(unsigned int *)len
{
    return NO;
}

- (void) stream: (NSStream *) theStream handleEvent: (NSStreamEvent) streamEvent;
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end

@implementation DDMultipartInputStream (Private)

- (void) buildBody;
{
    NSString * firstDelimiter = [NSString stringWithFormat: @"--%@\r\n", mBoundary];
    NSString * middleDelimiter = [NSString stringWithFormat: @"\r\n--%@\r\n", mBoundary];
    NSString * delimiter = firstDelimiter;
    
    NSEnumerator * e = [mParts objectEnumerator];
    DDMultipartDataPart * part;
    while (part = [e nextObject])
    {
        NSMutableData * headerData = [NSMutableData data];
        [headerData dd_appendUTF8Format: delimiter];
        [headerData dd_appendUTF8String: [part headersAsString]];
        NSInputStream * headerStream = [NSInputStream inputStreamWithData: headerData];
        [mPartStreams addObject: headerStream];
        
        [mPartStreams addObject: [part contentAsStream]];
        
        delimiter = middleDelimiter;
    }

    NSString * finalDelimiter = [NSString stringWithFormat: @"\r\n--%@--\r\n", mBoundary];
    NSData * finalDelimiterData = [finalDelimiter dataUsingEncoding: NSUTF8StringEncoding];
    NSInputStream * finalDelimiterStream = [NSInputStream inputStreamWithData: finalDelimiterData];
    [mPartStreams addObject: finalDelimiterStream];
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
    [headers appendFormat: @"Content-Type: %@\r\n", [path dd_pathMimeType]];
    [headers appendString: @"\r\n"];
    return [self initWithHeaders: headers
                   streamContent: [NSInputStream inputStreamWithFileAtPath: path]]; 
}

- (id) initWithHeaders: (NSString *) headers dataContent: (NSData *) data;
{
    return [self initWithHeaders: headers
                   streamContent: [NSInputStream inputStreamWithData: data]];
}

- (id) initWithHeaders: (NSString *) headers streamContent: (NSInputStream *) stream;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHeaders = [headers retain];
    mContentStream = [stream retain];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mHeaders release];
    [mContentStream release];
    
    mHeaders = nil;
    mContentStream = nil;
    [super dealloc];
}

- (NSString *) headersAsString;
{
    return mHeaders;
}

- (NSInputStream *) contentAsStream;
{
    return mContentStream;
}

@end
