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
    DDCurlMultipartForm * mForm;
    NSString * mUsername;
    NSString * mPassword;
}

#pragma mark -
#pragma mark Class Constructors

+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;

+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Constructors

- (id) initWithURL: (NSURL *) url;

#pragma mark -
#pragma mark Properties

- (NSURL *) URL;
- (void) setURL: (NSURL *) theURL;

- (NSString *) urlString;

- (NSString *) username;
- (void) setUsername: (NSString *) theUsername;

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

- (DDCurlMultipartForm *) form;
- (void) setForm: (DDCurlMultipartForm *) theForm;

@end
