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

@class DDMutableCurlRequest;
@class DDCurlResponse;
@class DDCurlMultipartForm;

@interface DDCurlCliApp : NSObject
{
    BOOL mShouldPrintHelp;
    BOOL mShouldPrintVersion;
    NSString * mCommand;

    DDMutableCurlRequest * mRequest;
    DDCurlMultipartForm * mForm;
    
    NSString * mUrl;
    NSMutableData * mBody;
    DDCurlResponse * mResponse;
    long long mBytesReceived;
    NSConditionLock * mLock;
    BOOL mShouldKeepRunning;
}

- (void) setUsername: (NSString *) theUsername;

- (void) setPassword: (NSString *) thePassword;

- (void) setHeader: (NSString *) header;

- (NSString *) url;
- (void) setUrl: (NSString *) theUrl;

- (void) help;
- (void) addFormField: (NSString *) formField;

- (int) run;

@end
