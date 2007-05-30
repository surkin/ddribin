//
//  DDCurlResponse.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDCurlResponse : NSObject
{
    long long mExpectedContentLength;
    int mStatusCode;
    NSMutableDictionary * mHeaders;
}

+ (DDCurlResponse *) response;

- (long long) expectedContentLength;
- (void) setExpectedContentLength: (long long) theExpectedContentLength;

- (int) statusCode;
- (void) setStatusCode: (int) theStatusCode;

- (void) setHeader: (NSString *) header withName: (NSString *) name;
- (NSString *) headerWithName: (NSString *) name;


@end
