//
//  DDHidElement.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidElement.h"
#import "DDHidUsageTables.h"
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
    
    return self;
}

- (NSDictionary *) properites;
{
    return mProperties;
}

- (NSString *) stringForKey: (NSString *) key;
{
    return [mProperties objectForKey: key];
}

- (unsigned) cookie;
{
    return [mProperties unsignedIntForString: kIOHIDElementCookieKey];
}

- (unsigned) usage;
{
    return [mProperties unsignedIntForString: kIOHIDElementUsageKey];
}

- (unsigned) usagePage;
{
    return [mProperties unsignedIntForString: kIOHIDElementUsagePageKey];
}

- (NSString *) usageDescription;
{
    DDHidUsageTables * usageTables = [DDHidUsageTables standardUsageTables];
    return [usageTables descriptionForUsagePage: [self usagePage]
                                          usage: [self usage]];
}

- (NSArray *) elements;
{
    NSArray * elementsProperties =
        [mProperties objectForString: kIOHIDElementKey];
    return [DDHidElement elementsWithPropertiesArray: elementsProperties];
}

@end
