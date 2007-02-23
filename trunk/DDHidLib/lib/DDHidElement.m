/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
