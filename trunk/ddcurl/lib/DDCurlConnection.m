//
//  DDCurlConnection.m
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDCurlConnection.h"
#import "DDMutableCurlRequest.h"
#import "DDCurlResponse.h"
#import "DDCurlMultipartForm.h"
#import "DDCurlEasy.h"
#import "DDCurlSlist.h"

@interface DDCurlConnection (Private)

- (void) threadMain: (DDMutableCurlRequest *) request;

#pragma mark -
#pragma mark Delegation

- (void) dd_curlConnection: (DDCurlConnection *) connection
           didReceiveBytes: (void *) bytes
                    length: (unsigned) length;
- (void) callDidReceiveBytesDelegate: (NSArray *) arguments;

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;
- (void) callDidReceiveResponse: (DDCurlResponse *) response;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;
- (void) callProgressDownload: (NSArray *) arguments;

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;


@end

@implementation DDCurlConnection

+ (DDCurlConnection *) alloc;
{
    return [super alloc];
}

- (id) initWithRequest: (DDMutableCurlRequest *) request
              delegate: delegate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mDelegate = delegate;
    mCurl = [[DDCurlEasy alloc] init];
    mResponse = [[DDCurlResponse alloc] init];
    [NSThread detachNewThreadSelector: @selector(threadMain:)
                             toTarget: self
                           withObject: request];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mCurl release];
    [mResponse release];
    
    mCurl = nil;
    mResponse = nil;
    [super dealloc];
}

- (void) setResponseInfo;
{
    NSString * contentLengthString = [mResponse headerWithName: @"Content-Length"];
    if (contentLengthString != nil)
    {
        long long contentLength = -1;
        NSScanner * scanner = [NSScanner scannerWithString: contentLengthString];
        if ([scanner scanLongLong: &contentLength])
        {
            [mResponse setExpectedContentLength: contentLength];
        }
    }
    
    [mResponse setStatusCode: [mCurl responseCode]];
    [mResponse setMIMEType: [mCurl contentType]];
    [self dd_curlConnection: self didReceiveResponse: mResponse];
}

- (size_t) writeData: (char *) buffer size: (size_t) size
               nmemb: (size_t) nmemb
{
    size_t bytes = size * nmemb;
    if (mIsFirstData)
    {
        [self setResponseInfo];
        mIsFirstData = NO;
    }
    
    [self dd_curlConnection: self
                 didReceiveBytes: buffer length: bytes];
    return bytes;
}

BOOL splitField(NSString * string, NSString * separator,
                NSString ** left, NSString ** right)
{
    NSRange range = [string rangeOfString: separator];
    if (range.location == NSNotFound)
        return NO;
    
    *left = [string substringToIndex: range.location];
    *right = [string substringFromIndex: range.location+1];
    return YES;
}

- (size_t) writeHeader: (char *) buffer size: (size_t) size
                 nmemb: (size_t) nmemb
{
    size_t length = size * nmemb;
    
    NSString * header = [NSString stringWithCString: buffer length: length];
    
    NSString * name;
    NSString * value;
    if (splitField(header, @":", &name, &value))
    {
        value = [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        [mResponse setHeader: value withName: name];
    }
    
    return length;
}

- (int) progressDownload: (double) download
           downloadTotal: (double) downloadTotal
                  upload: (double) upload
             uploadTotal: (double) uploadTotal;
{
    [self dd_curlConnection: self
                progressDownload: download
                   downloadTotal: downloadTotal
                          upload: upload
                     uploadTotal: uploadTotal];
    return 0;
}

static size_t staticWriteData(char * buffer, size_t size, size_t nmemb,
                              void * userData)
{
    DDCurlConnection * connection = (DDCurlConnection *) userData;
    return [connection writeData: buffer size: size nmemb: nmemb];
}

static size_t staticWriteHeader(char * buffer, size_t size, size_t nmemb,
                              void * userData)
{
    DDCurlConnection * connection = (DDCurlConnection *) userData;
    return [connection writeHeader: buffer size: size nmemb: nmemb];
}

static int staticProgress(void * clientp,
                             double dltotal,
                             double dlnow,
                             double ultotal,
                             double ulnow)
{
    DDCurlConnection * connection = (DDCurlConnection *) clientp;
    return [connection progressDownload: dlnow
                          downloadTotal: dltotal
                                 upload: ulnow
                            uploadTotal: ultotal];
}

@end

@implementation DDCurlConnection (Private)


- (void) threadMain: (DDMutableCurlRequest *) request
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    @try
    {
        [mCurl setWriteData: self];
        [mCurl setWriteFunction: staticWriteData];
        [mCurl setWriteHeaderData: self];
        [mCurl setWriteHeaderFunction: staticWriteHeader];
        [mCurl setProgressData: self];
        [mCurl setProgressFunction: staticProgress];
        [mCurl setProgress: YES];
        
        [mCurl setFollowLocation: YES];
        
        DDCurlMultipartForm * form = [request multipartForm];
        if (form != nil)
            [mCurl setForm: form];
        
        DDCurlSlist * headers = [DDCurlSlist slist];
        NSDictionary * allHeaders = [request allHeaders];
        NSString * name;
        NSEnumerator * e = [allHeaders keyEnumerator];
        while (name = [e nextObject])
        {
            NSString * value = [allHeaders objectForKey: name];
            NSString * header = [NSString stringWithFormat: @"%@: %@",
                name, value];
            [headers appendString: header];
        }
        [mCurl setHttpHeaders: headers];
        
        NSString * httpMethod = [request HTTPMethod];
        if (httpMethod != nil)
        {
            [mCurl setCustomRequest: httpMethod];
        }
        
        [mCurl setUser: [request username] password: [request password]];
        [mCurl setUrl: [request urlString]];
        
        mIsFirstData = YES;
        [mCurl perform];
        if (mIsFirstData)
            [self setResponseInfo];
        
#if 0
        if ([mResponse statusCode] == 401)
        {
            [mCurl setUser: @"foo" password: @"bar"];
            mIsFirstData = YES;
            [mCurl perform];
        }
#endif
        
        [self dd_curlConnectionDidFinishLoading: self];
    }
    @finally
    {
        [pool release];
    }
}

#pragma mark -
#pragma mark Delegation

- (void) dd_curlConnection: (DDCurlConnection *) connection
           didReceiveBytes: (void *) bytes
                    length: (unsigned) length;
{
    
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    NSArray * arguments = [NSArray arrayWithObjects:
        [NSValue valueWithPointer: bytes],
        [NSNumber numberWithUnsignedInt: length],
        nil];
    [self performSelectorOnMainThread: @selector(callDidReceiveBytesDelegate:)
                           withObject: arguments
                        waitUntilDone: YES];
}

- (void) callDidReceiveBytesDelegate: (NSArray *) arguments;
{
    void * bytes = [[arguments objectAtIndex: 0] pointerValue];
    unsigned length = [[arguments objectAtIndex: 1] unsignedIntValue];
    [mDelegate dd_curlConnection: self
                 didReceiveBytes: bytes
                          length: length];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    [self performSelectorOnMainThread: @selector(callDidReceiveResponse:)
                           withObject: response
                        waitUntilDone: YES];
}

- (void) callDidReceiveResponse: (DDCurlResponse *) response;
{
    [mDelegate dd_curlConnection: self didReceiveResponse: response];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    NSArray * arguments = [NSArray arrayWithObjects:
        [NSNumber numberWithDouble: download],
        [NSNumber numberWithDouble: downloadTotal],
        [NSNumber numberWithDouble: upload],
        [NSNumber numberWithDouble: uploadTotal],
        nil];
    [self performSelectorOnMainThread: @selector(callProgressDownload:)
                           withObject: arguments
                        waitUntilDone: YES];
}

- (void) callProgressDownload: (NSArray *) arguments;
{
    double download = [[arguments objectAtIndex: 0] doubleValue];
    double downloadTotal = [[arguments objectAtIndex: 1] doubleValue];
    double upload = [[arguments objectAtIndex: 2] doubleValue];
    double uploadTotal = [[arguments objectAtIndex: 3] doubleValue];
    [mDelegate dd_curlConnection: self
                progressDownload: download
                   downloadTotal: downloadTotal
                          upload: upload
                     uploadTotal: uploadTotal];
}

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    [mDelegate performSelectorOnMainThread: @selector(dd_curlConnectionDidFinishLoading:)
                                withObject: connection
                             waitUntilDone: YES];
}

@end
