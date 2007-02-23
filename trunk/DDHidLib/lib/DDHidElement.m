//
//  DDHidElement.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidElement.h"
#import "DDHidUsage.h"
#import "NSDictionary+DDHidExtras.h"
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
    unsigned usagePage = [mProperties ddhid_unsignedIntForString: kIOHIDElementUsagePageKey];
    unsigned usageId = [mProperties ddhid_unsignedIntForString: kIOHIDElementUsageKey];
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

- (NSString *) description;
{
    return [[self usage] usageNameWithIds];
}

- (IOHIDElementCookie) cookie;
{
    return (IOHIDElementCookie)
    [mProperties ddhid_unsignedIntForString: kIOHIDElementCookieKey];
}

- (unsigned) cookieAsUnsigned;
{
    return [mProperties ddhid_unsignedIntForString: kIOHIDElementCookieKey];
}

- (DDHidUsage *) usage;
{
    return mUsage;
}

- (NSArray *) elements;
{
    NSArray * elementsProperties =
    [mProperties ddhid_objectForString: kIOHIDElementKey];
    return [DDHidElement elementsWithPropertiesArray: elementsProperties];
}

- (BOOL) hasNullState;
{
    return [mProperties ddhid_boolForString: kIOHIDElementHasNullStateKey];
}

- (BOOL) hasPreferredState;
{
    return [mProperties ddhid_boolForString: kIOHIDElementHasNullStateKey];
}

- (BOOL) isArray;
{
    return [mProperties ddhid_boolForString: kIOHIDElementIsArrayKey];
}

- (BOOL) isRelative;
{
    return [mProperties ddhid_boolForString: kIOHIDElementIsRelativeKey];
}

- (BOOL) isWrapping;
{
    return [mProperties ddhid_boolForString: kIOHIDElementIsWrappingKey];
}

- (long) maxValue;
{
    return [mProperties ddhid_longForString: kIOHIDElementMaxKey];
}

- (long) minValue;
{
    return [mProperties ddhid_longForString: kIOHIDElementMinKey];
}


@end
