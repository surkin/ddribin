//
//  NSString+DDExtensions.h
//  ddcurl
//
//  Created by Dave Dribin on 6/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSString * DDMimeTypeForExtension(NSString * extension);

@interface NSString (DDExtensions)

- (NSString *) dd_pathMimeType;

- (BOOL) dd_splitOnFirstSeparator: (NSString *) separator
                             left: (NSString **) left
                            right: (NSString **) right;

@end
