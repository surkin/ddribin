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

@interface DDCurlCliApp : NSObject
{
    NSString * mUrl;
    NSMutableData * mBody;
    DDCurlResponse * mResponse;
    long long mBytesReceived;
    NSConditionLock * mLock;
}

- (NSString *) url;
- (void) setUrl: (NSString *) theUrl;

- (int) run;

@end
