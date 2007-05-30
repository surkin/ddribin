//
//  DDCurlResponse.m
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDCurlResponse.h"


@implementation DDCurlResponse

+ (DDCurlResponse *) response;
{
    return [[[self alloc] init] autorelease];
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHeaders = [[NSMutableDictionary alloc] init];
    mExpectedContentLength = -1;
    mStatusCode = 0;
    
    return self;
}

//=========================================================== 
//  expectedContentLength 
//=========================================================== 
- (long long) expectedContentLength
{
    return mExpectedContentLength;
}

- (void) setExpectedContentLength: (long long) theExpectedContentLength
{
    mExpectedContentLength = theExpectedContentLength;
}
//=========================================================== 
//  statusCode 
//=========================================================== 
- (int) statusCode
{
    return mStatusCode;
}

- (void) setStatusCode: (int) theStatusCode
{
    mStatusCode = theStatusCode;
}

- (void) setHeader: (NSString *) value withName: (NSString *) name;
{
    [mHeaders setObject: value forKey: [name lowercaseString]];
}

- (NSString *) headerWithName: (NSString *) name;
{
    return [mHeaders objectForKey: [name lowercaseString]];
}

@end
