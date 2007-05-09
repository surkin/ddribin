//
//  NSUrlCliApp.m
//  nsurl
//
//  Created by Dave Dribin on 5/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSUrlCliApp.h"

void ddfprintf(FILE * stream, NSString * format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString * string = [[NSString alloc] initWithFormat: format
                                               arguments: arguments];
    va_end(arguments);
    
    fprintf(stream, "%s", [string UTF8String]);
    [string release];
}

void ddprintf(NSString * format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString * string = [[NSString alloc] initWithFormat: format
                                               arguments: arguments];
    va_end(arguments);
    
    printf("%s", [string UTF8String]);
    [string release];
}

@interface NSUrlCliApp (Private)

- (NSURLResponse *) response;
- (void) setResponse: (NSURLResponse *) theResponse;

@end

@implementation NSUrlCliApp

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHeaders = [[NSMutableDictionary alloc] init];
    mAllowRedirects = NO;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrl release];
    [mFileHandle release];
    [mResponse release];
    [mHeaders release];
    [mUsername release];
    [mPassword release];
    
    mUrl = nil;
    mFileHandle = nil;
    mResponse = nil;
    mHeaders = nil;
    mUsername = nil;
    mPassword = nil;
    [super dealloc];
}

//=========================================================== 
//  url 
//=========================================================== 
- (NSString *) url
{
    return mUrl; 
}

- (void) setUrl: (NSString *) theUrl
{
    if (mUrl != theUrl)
    {
        [mUrl release];
        mUrl = [theUrl retain];
    }
}

//=========================================================== 
//  username 
//=========================================================== 
- (NSString *) username
{
    return mUsername; 
}

- (void) setUsername: (NSString *) theUsername
{
    if (mUsername != theUsername)
    {
        [mUsername release];
        mUsername = [theUsername retain];
    }
}

//=========================================================== 
//  password 
//=========================================================== 
- (NSString *) password
{
    return mPassword; 
}

- (void) setPassword: (NSString *) thePassword
{
    if (mPassword != thePassword)
    {
        [mPassword release];
        mPassword = [thePassword retain];
    }
}

- (void) setHeaderValue: (NSString *) headerValue;
{
    NSRange range = [headerValue rangeOfString: @":"];
    if (range.location == NSNotFound)
        return;
    
    NSString * header = [headerValue substringToIndex: range.location];
    NSString * value = [headerValue substringFromIndex: range.location+1];
    value = [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    [mHeaders setValue: value forKey: header];
}

//=========================================================== 
//  allowRedirects 
//=========================================================== 
- (BOOL) allowRedirects
{
    return mAllowRedirects;
}

- (void) setAllowRedirects: (BOOL) flag
{
    mAllowRedirects = flag;
}

- (BOOL) run;
{
    NSURL * url = [NSURL URLWithString: mUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url
                                                            cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval: 60.0];
    [request setAllHTTPHeaderFields: mHeaders];

    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request
                                                                   delegate: self];
    if (connection == nil)
    {
        ddfprintf(stderr, @"Could not create connection");
        return NO;
    }
    
    mFileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];

    
    mShouldKeepRunning = YES;
    mRanWithSuccess  = YES;
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    while (mShouldKeepRunning &&
           [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        // Empty
    }
    
    return mRanWithSuccess;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    
    ddfprintf(stderr, @"Connection failed! Error - %@ %@ %@",
              [error localizedDescription],
              [error localizedFailureReason],
              [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    mShouldKeepRunning = NO;
    mRanWithSuccess = NO;
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    [connection release];
    mShouldKeepRunning = NO;
}

- (void)connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
    long long expectedLength = [mResponse expectedContentLength];
    
    mBytesReceived = mBytesReceived + [data length];
    
    if (expectedLength != NSURLResponseUnknownLength)
    {
        // if the expected content length is
        // available, display percent complete
        float percentComplete=(mBytesReceived/(float)expectedLength)*100.0;
        fprintf(stderr, "\rPercent complete - %.1f     ", percentComplete);
        if (mBytesReceived == expectedLength)
            fprintf(stderr, "\n");
    }
    else
    {
        // if the expected content length is
        // unknown just log the progress
        fprintf(stderr, "Bytes received - %d\n", mBytesReceived);
    }

    [mFileHandle writeData: data];
}

- (void) connection: (NSURLConnection *) connection
 didReceiveResponse: (NSURLResponse *)response
{
    // reset the progress, this might be called multiple times
    mBytesReceived = 0;
    
    // retain the response to use later
    [self setResponse: response];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential * credential = [challenge proposedCredential];
    
    if ([challenge previousFailureCount] == 0)
    {
        credential = [NSURLCredential credentialWithUser: mUsername password: mPassword   persistence: NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential: credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge: challenge];
    }
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) redirectResponse
{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) redirectResponse;
    if (mAllowRedirects)
    {
        ddfprintf(stderr, @"Redirecting (%d) to: %@\n",
                  [httpResponse statusCode], [request URL]);
        return request;
    }
    else
    {
        ddfprintf(stderr, @"Canceling redirect (%d) to: %@\n",
                  [httpResponse statusCode], [request URL]);
        [connection cancel];
        mShouldKeepRunning = NO;
        mRanWithSuccess = NO;
        return nil;
    }
}

@end


@implementation NSUrlCliApp (Private)

//=========================================================== 
//  response 
//=========================================================== 
- (NSURLResponse *) response
{
    return mResponse; 
}

- (void) setResponse: (NSURLResponse *) theResponse
{
    if (mResponse != theResponse)
    {
        [mResponse release];
        mResponse = [theResponse retain];
    }
}

@end
