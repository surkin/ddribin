//
//  DDCurlCliApp.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum
{
    DDCurlCliAppNotDone,
    DDCurlCliAppDone,
};

@class DDCurlResponse;
@class DDCurlMultipartForm;

@interface DDCurlCliApp : NSObject
{
    BOOL mShouldPrintHelp;
    NSString * mCommand;
    DDCurlMultipartForm * mForm;
    
    NSString * mUsername;
    NSString * mPassword;
    
    NSString * mUrl;
    NSMutableData * mBody;
    DDCurlResponse * mResponse;
    long long mBytesReceived;
    NSConditionLock * mLock;
    BOOL mShouldKeepRunning;
}

- (NSString *) username;
- (void) setUsername: (NSString *) theUsername;

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

- (NSString *) url;
- (void) setUrl: (NSString *) theUrl;

- (void) help;
- (void) addFormField: (NSString *) formField;

- (int) run;

@end
