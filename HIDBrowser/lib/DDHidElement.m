//
//  DDHidElement.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidElement.h"
#import "DDHidUsage.h"
#import "NSDictionary+AccessHelpers.h"
#include <IOKit/hid/IOHIDKeys.h>

@implementation DDHidElement

+ (NSArray *) elementsWithPropertiesArray: (NSArray *) propertiesArray;
{
    NSMutableArray * elements = [NSMutableArray array];

    NSDictionary * properties;
    NSEnumerator * e = [propertiesArray objectEnumerator];
    while (properties = [e nextObject])
    {
        DDHidElement * element = [DDHidElement elementWithProperties: properties];
        [elements addObject: element];
    }
    
    return elements;
}

+ (DDHidElement *) elementWithProperties: (NSDictionary *) properties;
{
    DDHidElement * element = [[DDHidElement alloc] initWithProperties: properties];
    return [element autorelease];
}

- (id) initWithProperties: (NSDictionary *) properties;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mProperties = [properties retain];
    unsigned usagePage = [mProperties unsignedIntForString: kIOHIDElementUsagePageKey];
    unsigned usageId = [mProperties unsignedIntForString: kIOHIDElementUsageKey];
    mUsage = [[DDHidUsage alloc] initWithUsagePage: usagePage
                                           usageId: usageId];
    
    return self;
}

- (NSDictionary *) properties;
{
    return mProperties;
}

- (NSString *) stringForKey: (NSString *) key;
{
    return [mProperties objectForKey: key];
}

- (IOHIDElementCookie) cookie;
{
    return (IOHIDElementCookie)
        [mProperties unsignedIntForString: kIOHIDElementCookieKey];
}

- (unsigned) cookieAsUnsigned;
{
    return [mProperties unsignedIntForString: kIOHIDElementCookieKey];
}

- (DDHidUsage *) usage;
{
    return mUsage;
}

- (NSArray *) elements;
{
    NSArray * elementsProperties =
        [mProperties objectForString: kIOHIDElementKey];
    return [DDHidElement elementsWithPropertiesArray: elementsProperties];
}

- (BOOL) hasNullState;
{
    return [mProperties boolForString: kIOHIDElementHasNullStateKey];
}

- (BOOL) hasPreferredState;
{
    return [mProperties boolForString: kIOHIDElementHasNullStateKey];
}

- (BOOL) isArray;
{
    return [mProperties boolForString: kIOHIDElementIsArrayKey];
}

- (BOOL) isRelative;
{
    return [mProperties boolForString: kIOHIDElementIsRelativeKey];
}

- (BOOL) isWrapping;
{
    return [mProperties boolForString: kIOHIDElementIsWrappingKey];
}

- (long) maxValue;
{
    return [mProperties longForString: kIOHIDElementMaxKey];
}

- (long) minValue;
{
    return [mProperties longForString: kIOHIDElementMinKey];
}


@end
