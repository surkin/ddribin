//
//  DDHidElement.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/hid/IOHIDKeys.h>

@interface DDHidElement : NSObject
{
    NSDictionary * mProperties;
    DDHidElement * mChildren;
}

+ (NSArray *) elementsWithPropertiesArray: (NSArray *) propertiesArray;

+ (DDHidElement *) elementWithProperties: (NSDictionary *) properties;

- (id) initWithProperties: (NSDictionary *) properties;

- (NSDictionary *) properties;

- (NSString *) stringForKey: (NSString *) key;

- (IOHIDElementCookie) cookie;
- (unsigned) cookieAsUnsigned;

- (NSArray *) elements;
- (unsigned) usage;
- (unsigned) usagePage;
- (BOOL) hasNullState;
- (BOOL) hasPreferredState;
- (BOOL) isArray;
- (BOOL) isRelative;
- (BOOL) isWrapping;
- (long) maxValue;
- (long) minValue;


@end
