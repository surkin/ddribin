//
//  DDCurlMultipartForm.m
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDCurlMultipartForm.h"


@implementation DDCurlMultipartForm

+ (DDCurlMultipartForm *) form;
{
    return [[[self alloc] init] autorelease];
}

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mFirst = NULL;
    mLast = NULL;
    
    return self;
}

- (void) dealloc
{
    curl_formfree(mFirst);
    [super dealloc];
}

- (void) addString: (NSString *) string withName: (NSString *) name;
{
    curl_formadd(&mFirst, &mLast,
                 CURLFORM_COPYNAME, [name UTF8String],
                 CURLFORM_COPYCONTENTS, [string UTF8String],
                 CURLFORM_END);
}

- (void) addFile: (NSString *) path withName: (NSString *) name;
{
    curl_formadd(&mFirst, &mLast,
                 CURLFORM_COPYNAME, [name UTF8String],
                 CURLFORM_FILE, [[path stringByExpandingTildeInPath] UTF8String],
                 // CURLFORM_CONTENTTYPE, "image/jpeg",
                 CURLFORM_END);
}

- (struct curl_httppost *) curl_httppost;
{
    return mFirst;
}

@end
