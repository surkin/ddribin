/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <Cocoa/Cocoa.h>

@class DDMutableCurlRequest;
@class DDCurlResponse;
@class DDCurlEasy;
@class DDCurlSlist;

/**
 * Loads URLs using libcurl via DDCurlEasy.  The delegate methods 
 * allow an object to receive informational callbacks. 
 *
 * Note: To support asynchronous behavior, a new thread is spawned for each
 * connection.  The delegate methods are called on the main thread.
 */
@interface DDCurlConnection : NSObject
{
    DDCurlEasy * mCurl;
    DDCurlResponse * mResponse;
    DDCurlSlist * mHeaders;
    BOOL mIsFirstData;

    id mDelegate;
}

+ (DDCurlConnection *) alloc;

- (id) initWithRequest: (DDMutableCurlRequest *) request
              delegate: delegate;

@end

@interface NSObject (DDCurlConnectionDelegate)

- (void) dd_curlConnection: (DDCurlConnection *) connection
           didReceiveBytes: (void *) bytes
                    length: (unsigned) length;

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          didFailWithError: (NSError *) error;

@end

extern NSString * DDCurlDomain;

