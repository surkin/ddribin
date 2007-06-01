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

+ (DDMutableCurlRequest *) request;
{
    return [[[self alloc] init] autorelease];
}

+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;
{
    return [[[self alloc] initWithURL: url] autorelease];
}

+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;
{
    return [[[self alloc] initWithURLString: urlString] autorelease];
}

#pragma mark -
#pragma mark Constructors

- (id) init;
{
    return [self initWithURL: nil];
}

- (id) initWithURL: (NSURL *) url;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUrl = [url retain];
    mMultipartForm = nil;
    mHeaders = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (id) initWithURLString: (NSString *) urlString;
{
    return [self initWithURL: [NSURL URLWithString: urlString]];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrl release];
    [mMultipartForm release];
    [mUsername release];
    [mPassword release];
    
    mUrl = nil;
    mMultipartForm = nil;
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

- (void) setURLString: (NSString *) urlString;
{
    [self setURL: [NSURL URLWithString: urlString]];
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
//  multipartForm 
//=========================================================== 
- (DDCurlMultipartForm *) multipartForm
{
    return mMultipartForm; 
}

- (void) setMultipartForm: (DDCurlMultipartForm *) theMultipartForm
{
    if (mMultipartForm != theMultipartForm)
    {
        [mMultipartForm release];
        mMultipartForm = [theMultipartForm retain];
    }
}

//=========================================================== 
//  HTTPMethod 
//=========================================================== 
- (NSString *) HTTPMethod
{
    return mHTTPMethod; 
}

- (void) setHTTPMethod: (NSString *) theHTTPMethod
{
    if (mHTTPMethod != theHTTPMethod)
    {
        [mHTTPMethod release];
        mHTTPMethod = [theHTTPMethod retain];
    }
}

- (void) setValue: (NSString *) value forHTTPHeaderField: (NSString *) field;
{
    [mHeaders setObject: value forKey: [field lowercaseString]];
}

- (NSDictionary *) allHeaders;
{
    return mHeaders;
}

@end
