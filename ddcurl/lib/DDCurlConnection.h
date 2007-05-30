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

@interface DDCurlConnection : NSObject
{
    DDCurlEasy * mCurl;
    DDCurlResponse * mResponse;
    BOOL mIsFirstData;

    id mDelegate;
}

+ (DDCurlConnection *) alloc;

- (id) initWithRequest: (DDMutableCurlRequest *) request
              delegate: delegate;

@end

@interface NSObject (DDCurlConnectionDelegate)

- (void) dd_curlConnection: (DDCurlConnection *) connection
           didReceiveBytes: (void *) buffer
                    length: (unsigned) length;

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;

@end
