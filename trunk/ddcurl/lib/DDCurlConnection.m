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

- (void) callResponseDelegate;
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
    [mDelegate dd_curlConnection: self
              didReceiveResponse: mResponse];
}

- (size_t) writeData: (char *) buffer size: (size_t) size
               nmemb: (size_t) nmemb
{
    size_t bytes = size * nmemb;
    if (mIsFirstData)
    {
        [self callResponseDelegate];
        mIsFirstData = NO;
    }
    
    [mDelegate dd_curlConnection: self
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
    [mDelegate dd_curlConnection: self
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
            [self callResponseDelegate];
        
#if 0
        if ([mResponse statusCode] == 401)
        {
            [mCurl setUser: @"foo" password: @"bar"];
            mIsFirstData = YES;
            [mCurl perform];
        }
#endif

        [mDelegate dd_curlConnectionDidFinishLoading: self];
    }
    @finally
    {
        [pool release];
    }
}

@end
