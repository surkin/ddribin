//
//  NSUrlCliApp.m
//  nsurl
//
//  Created by Dave Dribin on 5/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSUrlCliApp.h"
#import "NSUrlExtensions.h"
#import "ddutil.h"

const char * COMMAND = 0;

@interface NSUrlCliApp (Private)

- (NSURLResponse *) response;
- (void) setResponse: (NSURLResponse *) theResponse;

@end

@implementation NSUrlCliApp

+ (void) initialize
{
    initializeDefaultCredentials();
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUrlRequest = [[NSMutableURLRequest alloc] init];
    [mUrlRequest setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    [mUrlRequest setTimeoutInterval: 60.0];
    [mUrlRequest setHTTPShouldHandleCookies: NO];
    
    mAllowRedirects = NO;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrlRequest release];
    [mFileHandle release];
    [mResponse release];
    [mUsername release];
    [mPassword release];
    
    mUrlRequest = nil;
    mFileHandle = nil;
    mResponse = nil;
    mUsername = nil;
    mPassword = nil;
    [super dealloc];
}

//=========================================================== 
//  url 
//=========================================================== 
- (NSString *) url
{
    return [[mUrlRequest URL] absoluteString];
}

- (void) setUrl: (NSString *) theUrl
{
    [mUrlRequest setURL: [NSURL URLWithString: theUrl]];
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

static BOOL parseHeaderValue(NSString * headerValue, NSString ** header,
                             NSString ** value)
{
    *header = nil;
    *value = nil;

    NSRange range = [headerValue rangeOfString: @":"];
    if (range.location == NSNotFound)
        return NO;
    
    *header = [headerValue substringToIndex: range.location];
    *value = [headerValue substringFromIndex: range.location+1];
    *value = [*value stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];
    return YES;
}

- (void) setHeaderValue: (NSString *) headerValue;
{
    NSString * header;
    NSString * value;
    if (!parseHeaderValue(headerValue, &header, &value))
        return;
    [mUrlRequest setValue: value forHTTPHeaderField: header];
}

- (void) addHeaderValue: (NSString *) headerValue;
{
    NSString * header;
    NSString * value;
    if (!parseHeaderValue(headerValue, &header, &value))
        return;
    [mUrlRequest addValue: value forHTTPHeaderField: header];
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
    NSURLConnection * connection =
        [[NSURLConnection alloc] initWithRequest: mUrlRequest
                                        delegate: self];
    if (connection == nil)
    {
        ddfprintf(stderr, @"%s: Could not create connection", COMMAND);
        return NO;
    }
    
    mFileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
    if (isatty([mFileHandle fileDescriptor]))
        mShowProgress = NO;
    else
        mShowProgress = YES;

    
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
    
    if ([[error domain] isEqualToString: NSURLErrorDomain] &&
        [error code] == NSURLErrorUserCancelledAuthentication)
    {
        ddfprintf(stderr, @"%s: Authorization required or invalid authorization\n", COMMAND);
    }
    else
    {
        ddfprintf(stderr, @"%s: Connection failed: %@ %@ %@\n",
                  COMMAND,
                  [error localizedDescription],
                  [error localizedFailureReason],
                  [[error userInfo] objectForKey: NSErrorFailingURLStringKey]);
    }
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
        if (mShowProgress)
        {
            float percentComplete=(mBytesReceived/(float)expectedLength)*100.0;
            fprintf(stderr, "Percent complete - %.1f\r", percentComplete);
            if (mBytesReceived == expectedLength)
                fprintf(stderr, "\n");
        }
    }
    else
    {
        // if the expected content length is
        // unknown just log the progress
        if (mShowProgress)
            fprintf(stderr, "Bytes received - %d\n", mBytesReceived);
    }

    [mFileHandle writeData: data];
}

- (void) connection: (NSURLConnection *) connection
 didReceiveResponse: (NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    int statusCode = [httpResponse statusCode];
    if ((statusCode == 200) || (statusCode == 201))
    {
        // reset the progress, this might be called multiple times
        mBytesReceived = 0;
        
        // retain the response to use later
        [self setResponse: response];
    }
    else
    {
        NSDictionary * headers = [httpResponse allHeaderFields];
        ddfprintf(stderr, @"%s: Received unsuccessful response: %@\n",
                  COMMAND, [headers valueForKey: @"Status"]);
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // ddfprintf(stderr, @"%@\n", NSStringFromSelector(_cmd));
    NSURLCredential * credential = [challenge proposedCredential];
    // ddfprintf(stderr, @"Proposed credential: %@, failure count: %d\n", credential, [challenge previousFailureCount]);
    
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

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    // ddfprintf(stderr, @"%@\n", NSStringFromSelector(_cmd));
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
