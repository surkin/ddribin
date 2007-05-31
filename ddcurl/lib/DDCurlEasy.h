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
}

- (void) setUrl: (NSString *) url;

- (void) setWriteData: (void *) writeData;

- (void) setWriteFunction: (curl_write_callback) writeFunction;

- (void) setWriteHeaderData: (void *) writeHeaderData;

- (void) setWriteHeaderFunction: (curl_write_callback) writeHeaderFunction;

- (void) setProgressData: (void *) progressData;

- (void) setProgressFunction: (curl_progress_callback) progressFunction;

- (void) setProgress: (BOOL) progress;

- (void) setFollowLocation: (BOOL) followLocation;

- (void) setUser: (NSString *) user password: (NSString *) password;

- (void) setCustomRequest: (NSString *) customRequest;

- (void) setHttpHeaders: (DDCurlSlist *) httpHeaders;

- (void) setCurlHttpHeaders: (struct curl_slist *) httpHeaders;

- (void) setForm: (DDCurlMultipartForm *) setForm;

- (void) setCurlHttpPost: (struct curl_httppost *) httpPost;

- (void) perform;

- (long) responseCode;

- (NSString *) contentType;

@end
