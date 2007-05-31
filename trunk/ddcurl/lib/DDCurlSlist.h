//
//  DDCurlSlist.h
//  JamLab
//
//  Created by Dave Dribin on 5/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct curl_slist;

@interface DDCurlSlist : NSObject
{
    struct curl_slist * mSlist;
    NSMutableArray * mUtf8Data;
}

+ (DDCurlSlist *) slist;

- (void) appendUtf8String: (const char *) string;

- (void) appendString: (NSString *) string;

- (void) freeAll;

- (struct curl_slist *) curl_slist;

@end
