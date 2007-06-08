//
//  DDCurlEasy.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <curl/curl.h>

@class DDCurlSlist;
@class DDCurlMultipartForm;

@interface DDCurlEasy : NSObject
{
    CURL * mCurl;
    NSMutableDictionary * mProperties;
    char mErrorBuffer[CURL_ERROR_SIZE];
}

+ (NSString *) errorString: (CURLcode) errorCode;

- (void) setUrl: (NSString *) url;

- (CURL *) CURL;

#pragma mark -
#pragma mark Callback functions

- (void) setWriteData: (void *) writeData;

- (void) setWriteFunction: (curl_write_callback) writeFunction;

- (void) setWriteHeaderData: (void *) writeHeaderData;

- (void) setWriteHeaderFunction: (curl_write_callback) writeHeaderFunction;

- (void) setProgressData: (void *) progressData;

- (void) setProgressFunction: (curl_progress_callback) progressFunction;

- (void) setSslCtxData: (void *) sslCtxData;

- (void) setSslCtxFunction: (curl_ssl_ctx_callback) sslCtxFunction;

#pragma mark -

- (void) setProgress: (BOOL) progress;

- (void) setFollowLocation: (BOOL) followLocation;

- (void) setUser: (NSString *) user password: (NSString *) password;

- (void) setCustomRequest: (NSString *) customRequest;

- (void) setHttpHeaders: (DDCurlSlist *) httpHeaders;

- (void) setCurlHttpHeaders: (struct curl_slist *) httpHeaders;

- (void) setForm: (DDCurlMultipartForm *) setForm;

- (void) setCurlHttpPost: (struct curl_httppost *) httpPost;

- (void) setCaInfo: (NSString *) caInfo;

- (CURLcode) perform;

- (long) responseCode;

- (NSString *) contentType;

- (const char *) errorBuffer;

- (NSString *) errorString;

@end
