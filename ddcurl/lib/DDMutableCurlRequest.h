//
//  DDMutableCurlRequest.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDCurlMultipartForm;

@interface DDMutableCurlRequest : NSObject
{
    NSURL * mUrl;
    DDCurlMultipartForm * mMultipartForm;
    NSString * mUsername;
    NSString * mPassword;
    NSString * mHTTPMethod;
    NSMutableDictionary * mHeaders;
}

#pragma mark -
#pragma mark Class Constructors

+ (DDMutableCurlRequest *) request;

+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;

+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Constructors

- (id) init;

- (id) initWithURL: (NSURL *) url;

- (id) initWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Properties

- (NSURL *) URL;
- (void) setURL: (NSURL *) theURL;

- (void) setURLString: (NSString *) urlString;

- (NSString *) urlString;

- (NSString *) username;
- (void) setUsername: (NSString *) theUsername;

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

- (DDCurlMultipartForm *) multipartForm;
- (void) setMultipartForm: (DDCurlMultipartForm *) theMultipartForm;

- (NSString *) HTTPMethod;
- (void) setHTTPMethod: (NSString *) theHTTPMethod;

- (void) setValue: (NSString *) value forHTTPHeaderField: (NSString *) field;

- (NSDictionary *) allHeaders;

@end
