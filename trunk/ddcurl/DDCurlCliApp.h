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
    // Options
    BOOL _help;
    BOOL _version;
    
    NSString * mCommand;

    DDMutableCurlRequest * mRequest;
    DDCurlMultipartForm * mForm;
    
    NSMutableData * mBody;
    DDCurlResponse * mResponse;
    long long mBytesReceived;
    NSConditionLock * mLock;
    BOOL mShouldKeepRunning;
}

#pragma mark -
#pragma mark Options Accessors

- (void) setUsername: (NSString *) theUsername;

- (void) setPassword: (NSString *) thePassword;

- (void) setHeader: (NSString *) header;

- (void) setForm: (NSString *) formField;

#pragma mark -

- (int) run;

@end
