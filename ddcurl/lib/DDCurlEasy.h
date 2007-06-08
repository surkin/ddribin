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

/**
 * An Objective-C wrapper around a CURL easy handle and the
 * curl_easy_*() functions.  This class provides a couple benefits
 * over the native C API.  First, all return code errors are
 * translated to exceptions.  This simplifies error handling, as the
 * return code does not need to be checked after every call.  Second,
 * this class takes care of memory management for data that needs to
 * be kept around until Curl is finished with it.
 */
@interface DDCurlEasy : NSObject
{
    CURL * mCurl;
    NSMutableDictionary * mProperties;
    char mErrorBuffer[CURL_ERROR_SIZE];
}

/**
 * Returns an error string for a CURL error code.
 *
 * @return An error string
 */
+ (NSString *) errorString: (CURLcode) errorCode;

/**
 * Returns the CURL easy handle, for direct manipulation.
 *
 * @return CURL CURL Eash handle
 */
- (CURL *) CURL;

#pragma mark -
#pragma mark Options

/**
 * Sets URL to deal with (CURLOPT_URL).
 *
 * @param url The actual URL to deal with.
 */
- (void) setUrl: (NSString *) url;

/**
 * Sets CURLOPT_NOPROGRESS.
 *
 * @param progress YES to enable the progress callback
 */
- (void) setProgress: (BOOL) progress;

/**
 * Sets CURLOPT_FOLLOWLOCATION.
 *
 * @param followLocation YES to follow redirect headers.
 */
- (void) setFollowLocation: (BOOL) followLocation;

/**
 * Sets CURLOPT_USERPWD.
 *
 * @param user Username
 * @param password Password
 */
- (void) setUser: (NSString *) user password: (NSString *) password;

/**
 * Sets CURLOPT_CUSTOMREQUEST.
 *
 * @param customRequest Custom request string
 */
- (void) setCustomRequest: (NSString *) customRequest;

/**
 * Sets CURLOPT_HTTPHEADER.
 *
 * @param httpHeaders Header linked list wrapper object
 */
- (void) setHttpHeaders: (DDCurlSlist *) httpHeaders;

/**
 * Sets CURLOPT_HTTPHEADER.
 *
 * @param httpHeaders Header linked list
 */
- (void) setCurlHttpHeaders: (struct curl_slist *) httpHeaders;

/**
 * Sets CURLOPT_HTTPPOST.
 *
 * @param httpPost HTTP post linked list wrapper object
 */
- (void) setHttpPost: (DDCurlMultipartForm *) httpPost;

/**
 * Sets CURLOPT_HTTPPOST.
 *
 * @param httpPost HTTP post linkned list
 */
- (void) setCurlHttpPost: (struct curl_httppost *) httpPost;

/**
 * Sets CURLOPT_CAINFO.
 *
 * @param caInfo File name of certificate authority info
 */
- (void) setCaInfo: (NSString *) caInfo;

#pragma mark -

/**
 * Perform the transfer.  This method does not throw exceptions, so the
 * return code should be checked for errors.
 *
 * @return CURL error code
 */
- (CURLcode) perform;

/**
 * Returns the error buffer as a null terminated C string.
 *
 * @return Error buffer
 */
- (const char *) errorBuffer;

/**
 * Returns the error string.
 *
 * @return Error string
 */
- (NSString *) errorString;

#pragma mark -
#pragma mark Informational

/**
 * Gets CURLINFO_RESPONSE_CODE.
 */
- (long) responseCode;

/**
 * Gets CURLINFO_CONTENT_TYPE
 */
- (NSString *) contentType;

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

@end
