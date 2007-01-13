//
//  NSDictionary+AccessHelpers.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDictionary (AccessHelpers)

- (unsigned) unsignedForKey: (NSString *) key;

- (id) objectForString: (const char *) key;
- (NSString *) stringForString: (const char *) key;
- (long) longForString: (const char *) key;
- (unsigned int) unsignedIntForString: (const char *) key;
- (BOOL) boolForString: (const char *) key;

@end
