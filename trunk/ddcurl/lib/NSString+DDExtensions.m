//
//  NSString+DDExtensions.m
//  ddcurl
//
//  Created by Dave Dribin on 6/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSString+DDExtensions.h"


NSString * DDMimeTypeForExtension(NSString * extension)
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (CFStringRef) extension, NULL);
    
    CFStringRef cfMime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
    CFRelease(uti);
    
    if (cfMime == NULL)
        return @"application/octet-stream";
    
    NSString * mime = [NSString stringWithString: (NSString *) cfMime];
    CFRelease(cfMime);
    
    return mime;
}

@implementation NSString (DDExtensions)

- (NSString *) dd_pathMimeType;
{
    return DDMimeTypeForExtension([self pathExtension]);
}

- (BOOL) dd_splitOnFirstSeparator: (NSString *) separator
                             left: (NSString **) left
                            right: (NSString **) right;
{
    NSRange range = [self rangeOfString: separator];
    if (range.location == NSNotFound)
        return NO;
    
    *left = [self substringToIndex: range.location];
    *right = [self substringFromIndex: range.location+1];
    return YES;
}

@end
