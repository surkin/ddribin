//
//  NSUrlCliApp.h
//  nsurl
//
//  Created by Dave Dribin on 5/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSUrlCliApp : NSObject
{
    NSMutableURLRequest * mUrlRequest;
    NSFileHandle * mFileHandle;
    NSURLResponse * mResponse;
    unsigned mBytesReceived;
    
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

- (BOOL) run;

@end

extern const char * COMMAND;