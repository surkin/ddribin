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
    NSString * mUrl;
    NSFileHandle * mFileHandle;
    NSURLResponse * mResponse;
    NSMutableDictionary * mHeaders;
    unsigned mBytesReceived;
    
    NSString * mUsername;
    NSString * mPassword;
    
    BOOL mShouldKeepRunning;
    BOOL mRanWithSuccess;
}

- (NSString *) url;
- (void) setUrl: (NSString *) theUrl;

- (NSString *) username;
- (void) setUsername: (NSString *) theUsername;

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

- (void) setHeaderValue: (NSString *) headerValue;

- (BOOL) run;

@end
