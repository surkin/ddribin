//
//  DDCurlConnection.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

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

