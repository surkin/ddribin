//
//  NSString+DDExtensions.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
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

@end
