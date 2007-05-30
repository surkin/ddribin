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

@implementation DDCurlCliApp

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

- (int) run;
{
    mBody = [[NSMutableData alloc] init];
    mLock = [[NSConditionLock alloc] initWithCondition: DDCurlCliAppNotDone];
    
    NSString * url = nil;
    if (url == nil)
    {
        // url = @"http://www.dribin.org/";
        // url = @"http://curl.haxx.se/download/curl-7.16.2.tar.bz2";
        // url = @"http://localhost/~dave/upload/private/uploader.php";
        url = @"http://www.dribin.org/dave/upload/private/uploader.php";
    }

    DDMutableCurlRequest * request = [DDMutableCurlRequest requestWithURLString: url];
    DDCurlMultipartForm * form = [DDCurlMultipartForm form];
    [form addFile: @"/tmp/ending.mp3" withName: @"uploadedfile"];
    // [form addFile: @"~/Desktop/07_raven_entry.pdf" withName: @"uploadedfile"];
    // [form addFile: @"~/mspacman.png" withName: @"uploadedfile"];
    [request setForm: form];
    
    [request setUsername: @"foo"];
    [request setPassword: @"bar"];
    
    DDCurlConnection * connection = [[DDCurlConnection alloc] initWithRequest: request
                                                                     delegate: self];
    if (connection == nil)
    {
        NSLog(@"Could not create connection");
        return 1;
    }
    
    [mLock lockWhenCondition: DDCurlCliAppDone];

    fprintf(stderr, "\n");
#if 1
    NSLog(@"Data: %@", [[[NSString alloc] initWithData: mBody
                                              encoding: NSUTF8StringEncoding] autorelease]);
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
    [mLock unlockWithCondition: DDCurlCliAppDone];
    [connection release];
}

@end
