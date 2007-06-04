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

@interface DDCurlCliApp (Private)

- (void) printUsage: (FILE *) stream;

- (void) printVersion;

@end

@implementation DDCurlCliApp

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _help = NO;
    _version = NO;
    
    mRequest = [[DDMutableCurlRequest alloc] init];
    
    return self;
}

#pragma mark -
#pragma mark Options Accessors

//=========================================================== 
//  username 
//=========================================================== 
- (void) setUsername: (NSString *) username
{
    [mRequest setUsername: username];
}

//=========================================================== 
//  password 
//=========================================================== 
- (void) setPassword: (NSString *) password
{
    [mRequest setPassword: password];
}

- (void) setHeader: (NSString *) header;
{
    NSString * name;
    NSString * value;
    if (![header dd_splitOnFirstSeparator: @":" left: &name right: &value])
    {
        fprintf(stderr, "Not a valid header: %s", [header UTF8String]);
        return;
    }
    
    value = [value stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];
    
    [mRequest setValue: value forHTTPHeaderField: name];
}

- (void) setForm: (NSString *) formField;
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

- (void) printHelp;
{
    [self printUsage: stdout];
    printf("\n");
    printf("  -u, --username USERNAME       Use USERNAME for authentication\n");
    printf("  -p, --password PASSWORD       Use PASSWORD for authentication\n");
    printf("  -H, --header HEADER           "
           "Set HTTP header, e.g. \"Accept: application/xml\"\n");
    // printf("  -A, --add-header HEADER       "
    //        "Add HTTP header, e.g. \"Accept: application/xml\"\n");
    // printf("  -r, --redirect                Follow redirects\n");
    printf("  -F, --form FIELD              Multipart form field\n");
    // printf("  -m, --method METHOD           HTTP method to use\n");
    printf("  -h, --help                    Display this help and exit\n");
    // printf("      --debug                   Dispaly debugging information\n");
    printf("      --version                 Display version and exit\n");
    printf("\n");
}

#pragma mark -
#pragma mark DDCliApplicationDelegate

- (void) application: (DDCliApplication *) app
    willParseOptions: (DDGetoptLong *) options;
{
    static DDGetoptOption optionTable[] = 
    {
        {@"header",     'H',    DDGetoptRequiredArgument},
        {@"form",       'F',    DDGetoptRequiredArgument},
        {@"username",   'u',    DDGetoptRequiredArgument},
        {@"password",   'p',    DDGetoptRequiredArgument},
        {@"help",       'h',    DDGetoptNoArgument},
        {@"version",    0,      DDGetoptNoArgument},
        {nil,           0,      0},
    };
    [options addOptionsFromTable: optionTable];
}

- (void) application: (DDCliApplication *) app
          printUsage: (FILE *) stream;
{
    [self printUsage: stream];
}

- (int) application: (DDCliApplication *) app
   runWithArguments: (NSArray *) arguments;
{
    if (_help)
    {
        [self printHelp];
        return 0;
    }
    
    if (_version)
    {
        [self printVersion];
        return 0;
    }
    
    if ([arguments count] != 1)
    {
        fprintf(stderr, "%s: missing url argument\n", [[app name] UTF8String]);
        fprintf(stderr, "Try `%s --help` for more information.\n", [[app name] UTF8String]);
        return 1;
    }
    NSString * url = [arguments objectAtIndex: 0];
    
    mBody = [[NSMutableData alloc] init];
    mShouldKeepRunning = YES;

    if (mForm != nil)
        [mRequest setMultipartForm: mForm];
    
    [mRequest setURLString: url];
    DDCurlConnection * connection = [[DDCurlConnection alloc] initWithRequest: mRequest
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
    
    if (mError != nil)
    {
        ddprintf(@"%@: %@\n", [app name], [mError localizedFailureReason]);
        return 1;
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

- (void) dd_curlConnection: (DDCurlConnection *) connection
          didFailWithError: (NSError *) error;
{
    mShouldKeepRunning = NO;
    [connection release];
    mError = [error retain];
}

@end

@implementation DDCurlCliApp (Private)

- (void) printUsage: (FILE *) stream;
{
    fprintf(stream, "Usage: %s [OPTIONS] <url>\n", [[DDCliApp name] UTF8String]);
}

- (void) printVersion;
{
    printf("%s version xxx\n", [[DDCliApp name] UTF8String]);
}

@end

