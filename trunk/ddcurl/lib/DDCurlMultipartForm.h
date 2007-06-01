//
//  DDCurlMultipartForm.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <curl/curl.h>

@interface DDCurlMultipartForm : NSObject
{
    struct curl_httppost * mFirst;
    struct curl_httppost * mLast;
}

+ (DDCurlMultipartForm *) form;

- (void) addString: (NSString *) string withName: (NSString *) name;

- (void) addInt: (int) number withName: (NSString *) name;

- (void) addFile: (NSString *) path withName: (NSString *) name;

- (void) addFile: (NSString *) path withName: (NSString *) name
     contentType: (NSString *) contentType;

- (struct curl_httppost *) curl_httppost;

@end
