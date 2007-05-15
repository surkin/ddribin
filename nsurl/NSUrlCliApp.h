//
//  NSUrlCliApp.h
//  nsurl
//
//  Created by Dave Dribin on 5/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDMultipartInputStream;

@interface NSUrlCliApp : NSObject
{
    NSMutableURLRequest * mUrlRequest;
    NSFileHandle * mFileHandle;
    NSURLResponse * mResponse;
    unsigned mBytesReceived;
    
    NSMutableDictionary * mFormFields;
    DDMultipartInputStream * mMultipartInputStream;
    
    NSString * mUsername;
    NSString * mPassword;
    
    BOOL mShouldKeepRunning;
    BOOL mRanWithSuccess;
    BOOL mAllowRedirects;
    BOOL mShowProgress;
}

- (NSString *) url;
- (void) setUrl: (NSString *) theUrl;

- (NSString *) username;
- (void) setUsername: (NSString *) theUsername;

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

- (void) setHeaderValue: (NSString *) headerValue;
- (void) addHeaderValue: (NSString *) headerValue;

- (BOOL) allowRedirects;
- (void) setAllowRedirects: (BOOL) flag;

- (void) addFormField: (NSString *) formField;

- (BOOL) run;

@end

extern const char * COMMAND;