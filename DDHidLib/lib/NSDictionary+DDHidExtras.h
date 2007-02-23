//
//  NSDictionary+DDHidExtras.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDictionary (DDHidExtras)

- (unsigned) ddhid_unsignedForKey: (NSString *) key;

- (id) ddhid_objectForString: (const char *) key;

- (NSString *) ddhid_stringForString: (const char *) key;
- (long) ddhid_longForString: (const char *) key;
- (unsigned int) ddhid_unsignedIntForString: (const char *) key;
- (BOOL) ddhid_boolForString: (const char *) key;

@end

@interface NSMutableDictionary (DDHidExtras)

- (void) ddhid_setObject: (id) object forString: (const char *) key;

@end
