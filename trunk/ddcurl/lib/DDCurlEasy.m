//
//  DDCurlEasy.m
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDCurlEasy.h"
#import "DDCurlMultipartForm.h"

@interface DDCurlEasy (Private)

- (void) assert: (CURLcode) errorCode
        message: (NSString *) message, ...;

- (void) setProperty: (id) property forOption: (int) option;

- (const char *) savedUTF8String: (NSString *) string forOption: (int) option;

@end

@implementation DDCurlEasy

#pragma mark -
#pragma mark Constructors

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mCurl = curl_easy_init();
    mProperties = [[NSMutableDictionary alloc] init];

    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mProperties release];
    curl_easy_cleanup(mCurl);
    
    mProperties = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

- (void) setWriteData: (void *) writeData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_WRITEDATA, writeData)
         message: @"set write data"];
}

- (void) setWriteFunction: (curl_write_callback) writeFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_WRITEFUNCTION, writeFunction)
         message: @"set write function"];
}

- (void) setWriteHeaderData: (void *) writeHeaderData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_WRITEHEADER, writeHeaderData)
         message: @"set write header data"];
}

- (void) setWriteHeaderFunction: (curl_write_callback) writeHeaderFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_HEADERFUNCTION, writeHeaderFunction)
         message: @"set write header function"];
}

- (void) setProgressData: (void *) progressData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_PROGRESSDATA, progressData)
         message: @"set progress data"];
}

- (void) setProgressFunction: (curl_progress_callback) progressFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_PROGRESSFUNCTION, progressFunction)
         message: @"set progress function"];
}

- (void) setProgress: (BOOL) progress;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_NOPROGRESS, !progress)
         message: @"set progress"];
}

- (void) setFollowLocation: (BOOL) followLocation;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_FOLLOWLOCATION, followLocation)
         message: @"set follow location"];
}

- (void) setUrl: (NSString *) url;
{
    const char * utf8String = [self savedUTF8String: url forOption: CURLOPT_URL];
    [self assert: curl_easy_setopt(mCurl, CURLOPT_URL, utf8String)
         message: @"set url"];
}

- (void) setUser: (NSString *) user password: (NSString *) password;
{
    NSString * userPassword = [NSString stringWithFormat: @"%@:%@", user, password];
    const char * utf8String = [self savedUTF8String: userPassword forOption: CURLOPT_USERPWD];
    [self assert: curl_easy_setopt(mCurl, CURLOPT_USERPWD, utf8String)
         message: @"set user/password"];
}

- (void) setForm: (DDCurlMultipartForm *) form;
{
    [self setCurlHttpPost: [form curl_httppost]];
    [self setProperty: form forOption: CURLOPT_HTTPPOST];
}

- (void) setCurlHttpPost: (struct curl_httppost *) httpPost;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_HTTPPOST, httpPost)
         message: @"set HTTP post"];
}

- (void) perform;
{
    [self assert: curl_easy_perform(mCurl)
         message: @"perform"];
}

- (long) responseCode;
{
    long responseCode;
    [self assert: curl_easy_getinfo(mCurl, CURLINFO_RESPONSE_CODE, &responseCode)
         message: nil];
    return responseCode;
}

@end

@implementation DDCurlEasy (Private)

- (void) assert: (CURLcode) errorCode
        message: (NSString *) message, ...;
{
    if (errorCode != CURLE_OK)
    {
        const char * curlError = curl_easy_strerror(errorCode);
        NSMutableString * reason = [NSMutableString string];
        
        if (message != nil)
        {
            va_list arguments;
            va_start(arguments, message);
            NSString * prefix = [[NSString alloc] initWithFormat: message
                                                       arguments: arguments];
            [prefix autorelease];
            va_end(arguments);
            
            [reason appendFormat: @"Coult not %@: ", prefix];
        }
        
        [reason appendFormat: @"curl error #%d (%s)", errorCode, curlError];
        
#if 0
        if (mUseErrorBuffer)
        {
            message << ": " << mErrorBuffer;
        }
#endif
        NSException * exception = [NSException exceptionWithName: @"CurlException"
                                                          reason: reason
                                                        userInfo: nil];
        @throw exception;
    }
}

- (void) setProperty: (id) property forOption: (int) option;
{
    [mProperties setObject: property forKey: [NSNumber numberWithInt: option]];
}

- (const char *) savedUTF8String: (NSString *) string forOption: (int) option;
{
    NSMutableData * data = [NSMutableData dataWithData:
        [string dataUsingEncoding: NSUTF8StringEncoding]];
    char null = '\0';
    [data appendBytes: &null length: 1];
    
    [self setProperty: data forOption: option];
    return [data bytes];
}


@end
