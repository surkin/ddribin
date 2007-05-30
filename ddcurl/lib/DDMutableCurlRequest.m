//
//  DDMutableCurlRequest.m
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMutableCurlRequest.h"


@implementation DDMutableCurlRequest

#pragma mark -
#pragma mark Class Constructors

+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;
{
    return [[[self alloc] initWithURL: url] autorelease];
}

+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;
{
    return [self requestWithURL: [NSURL URLWithString: urlString]];
}

#pragma mark -
#pragma mark Constructors

- (id) initWithURL: (NSURL *) url;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUrl = [url retain];
    mForm = nil;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrl release];
    [mForm release];
    [mUsername release];
    [mPassword release];
    
    mUrl = nil;
    mForm = nil;
    mUsername = nil;
    mPassword = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

//=========================================================== 
//  URL 
//=========================================================== 
- (NSURL *) URL
{
    return mUrl; 
}

- (void) setURL: (NSURL *) theURL
{
    if (mUrl != theURL)
    {
        [mUrl release];
        mUrl = [theURL retain];
    }
}

- (NSString *) urlString;
{
    return [mUrl absoluteString];
}
//=========================================================== 
//  username 
//=========================================================== 
- (NSString *) username
{
    return mUsername; 
}

- (void) setUsername: (NSString *) theUsername
{
    if (mUsername != theUsername)
    {
        [mUsername release];
        mUsername = [theUsername retain];
    }
}

//=========================================================== 
//  password 
//=========================================================== 
- (NSString *) password
{
    return mPassword; 
}

- (void) setPassword: (NSString *) thePassword
{
    if (mPassword != thePassword)
    {
        [mPassword release];
        mPassword = [thePassword retain];
    }
}

//=========================================================== 
//  form 
//=========================================================== 
- (DDCurlMultipartForm *) form
{
    return mForm; 
}

- (void) setForm: (DDCurlMultipartForm *) theForm
{
    if (mForm != theForm)
    {
        [mForm release];
        mForm = [theForm retain];
    }
}

@end
