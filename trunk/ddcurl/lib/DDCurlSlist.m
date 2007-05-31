//
//  DDCurlSlist.m
//  JamLab
//
//  Created by Dave Dribin on 5/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDCurlSlist.h"
#import <curl/curl.h>


@implementation DDCurlSlist

+ (DDCurlSlist *) slist;
{
    return [[[self alloc] init] autorelease];
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mSlist = 0;
    mUtf8Data = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc;
{
    [self freeAll];
    [super dealloc];
}

- (void) appendUtf8String: (const char *) string;
{
    struct curl_slist * temp = curl_slist_append(mSlist, string);
    if (temp == 0)
    {
        NSLog(@"Could not slist_append: %s", string);
        return;
    }
    
    mSlist = temp;
}

- (void) appendString: (NSString *) string;
{
    NSMutableData * utf8Data = [NSMutableData dataWithData:
        [string dataUsingEncoding: NSUTF8StringEncoding]];
    char null = '\0';
    [utf8Data appendBytes: &null length: 1];
    [mUtf8Data addObject: utf8Data];
    [self appendUtf8String: [utf8Data bytes]];
}

- (void) freeAll;
{
    [mUtf8Data removeAllObjects];
    if (mSlist != 0)
    {
        curl_slist_free_all(mSlist);
        mSlist = 0;
    }
}

- (struct curl_slist *) curl_slist;
{
    return mSlist;
}

@end
