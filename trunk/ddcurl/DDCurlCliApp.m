//
//  DDCurlCliApp.m
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDCurlCliApp.h"
#import "DDCurlConnection.h"
#import "DDCurl.h"
#import "DDGetoptLong.h"
#import "DDExtensions.h"

@implementation DDCurlCliApp

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mCommand = [[NSProcessInfo processInfo] processName];
    mShouldPrintHelp = NO;
    
    return self;
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

- (void) addFormField: (NSString *) formField;
{
    NSString * name;
    NSString * value;
    if (![formField dd_splitOnFirstSeparator: @"=" left: &name right: &value])
    {
        fprintf(stderr, "Not a valid field form: %s", [formField UTF8String]);
        return;
    }

    if (mForm == nil)
    {
        mForm = [[DDCurlMultipartForm alloc] init];
    }
    
    if ([value hasPrefix: @"@"])
    {
        value = [value substringFromIndex: 1];
        value = [value stringByExpandingTildeInPath];
        [mForm addFile: value withName: name];
    }
    else
    {
        [mForm addString: value withName: name];
    }
}

- (void) help;
{
    mShouldPrintHelp = YES;
}

- (void) printUsage: (FILE *) stream;
{
    fprintf(stream, "Usage: %s [OPTIONS] <url>\n", [mCommand UTF8String]);
}

- (void) printHelp;
{
    [self printUsage: stdout];
    printf("\n");
    printf("  -u, --username USERNAME       Use USERNAME for authentication\n");
    printf("  -p, --password PASSWORD       Use PASSWORD for authentication\n");
    // printf("  -H, --header HEADER           "
    //        "Set HTTP header, e.g. \"Accept: application/xml\"\n");
    // printf("  -A, --add-header HEADER       "
    //        "Add HTTP header, e.g. \"Accept: application/xml\"\n");
    // printf("  -r, --redirect                Follow redirects\n");
    printf("  -F, --form FIELD              Multipart form field\n");
    // printf("  -m, --method METHOD           HTTP method to use\n");
    printf("  -h, --help                    Display this help and exit\n");
    // printf("      --debug                   Dispaly debugging information\n");
    // printf("      --version                 Display version and exit\n");
    printf("\n");
}

- (int) run;
{
    DDGetoptLong * options = [DDGetoptLong optionsWithTarget: self];
    [options addLongOption: @"header"
               shortOption: 'H'
                  selector: @selector(setHeader:)
           argumentOptions: DDGetoptRequiredArgument];

    [options addLongOption: @"form"
               shortOption: 'F'
                  selector: @selector(addFormField:)
           argumentOptions: DDGetoptRequiredArgument];
    
    [options addLongOption: @"username"
               shortOption: 'u'
                  selector: @selector(setUsername:)
           argumentOptions: DDGetoptRequiredArgument];

    [options addLongOption: @"password"
               shortOption: 'p'
                  selector: @selector(setPassword:)
           argumentOptions: DDGetoptRequiredArgument];
    

    [options addLongOption: @"help"
               shortOption: 'h'
                  selector: @selector(help)
           argumentOptions: DDGetoptNoArgument];
    
    NSArray * arguments = [options processOptions];
    if (arguments == nil)
    {
        [self printUsage: stderr];
        return 1;
    }

    if (mShouldPrintHelp)
    {
        [self printHelp];
        return 0;
    }
    
    if ([arguments count] != 1)
    {
        fprintf(stderr, "%s: missing url argument\n", [mCommand UTF8String]);
        fprintf(stderr, "Try `%s --help` for more information.\n", [mCommand UTF8String]);
        return 1;
    }
    NSString * url = [arguments objectAtIndex: 0];
    
    mBody = [[NSMutableData alloc] init];
    mShouldKeepRunning = YES;

    DDMutableCurlRequest * request = [DDMutableCurlRequest requestWithURLString: url];
    [request setUsername: mUsername];
    [request setPassword: mPassword];
    if (mForm != nil)
        [request setMultipartForm: mForm];
    
    DDCurlConnection * connection = [[DDCurlConnection alloc] initWithRequest: request
                                                                     delegate: self];
    if (connection == nil)
    {
        NSLog(@"Could not create connection");
        return 1;
    }
    
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    while (mShouldKeepRunning &&
           [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        // Empty
    }

    fprintf(stderr, "\n");
#if 1
    NSString * bodyString = [[[NSString alloc] initWithData: mBody
                                                   encoding: NSUTF8StringEncoding] autorelease];
    printf("Data: %s\n", [bodyString UTF8String]);
#endif
    
    return 0;
}


- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;
{
    NSLog(@"Status code: %d", [response statusCode]);
    NSLog(@"Expected content length: %lld", [response expectedContentLength]);
    mResponse = [response retain];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
           didReceiveBytes: (void *) bytes
                    length: (unsigned) length;
{
    [mBody appendBytes: bytes length: length];
    long long expectedLength = [mResponse expectedContentLength];
    
    mBytesReceived = mBytesReceived + length;
    
    if (expectedLength != NSURLResponseUnknownLength)
    {
        // if the expected content length is
        // available, display percent complete
        if (NO) // mShowProgress)
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
        if (NO) // mShowProgress)
            fprintf(stderr, "Bytes received - %d\n", mBytesReceived);
    }
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;
{
    NSString * downloadStatus = nil;
    if (downloadTotal != 0)
    {
        double percentDown = download/downloadTotal*100;
        downloadStatus = [NSString stringWithFormat: @"%.1f%%", percentDown];
    }
    else
    {
        downloadStatus = [NSString stringWithFormat: @"%.0f bytes", download];
    }

    NSString * uploadStatus = nil;
    if (uploadTotal != 0)
    {
        double percentUp = upload/uploadTotal*100;
        uploadStatus = [NSString stringWithFormat: @"%.1f%%", percentUp];
    }
    else
    {
        uploadStatus = [NSString stringWithFormat: @"%.0f bytes", upload];
    }

    fprintf(stderr, "Download: %s, upload: %s\r", [downloadStatus UTF8String],
            [uploadStatus UTF8String]);
}

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;
{
    // [mLock unlockWithCondition: DDCurlCliAppDone];
    mShouldKeepRunning = NO;
    [connection release];
}

@end
