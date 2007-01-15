//
//  NSDictionary+AccessHelpers.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+AccessHelpers.h"


@implementation NSDictionary (AccessHelpers)

- (unsigned) unsignedForKey: (NSString *) key;
{
    NSNumber * number = [self objectForKey: key];
    return [number unsignedIntValue];
}

- (id) objectForString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithCString: key];
    return [self objectForKey: objcKey];
}

- (void) setObject: (id) object forString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithCString: key];
    [self setObject: object forKey: objcKey];
}

- (NSString *) stringForString: (const char *) key;
{
    return [self objectForString: key];
}

- (long) longForString: (const char *) key;
{
    NSNumber * number =  [self objectForString: key];
    return [number longValue];
}

- (unsigned int) unsignedIntForString: (const char *) key;
{
    NSNumber * number =  [self objectForString: key];
    return [number unsignedIntValue];
}

- (BOOL) boolForString: (const char *) key;
{
    NSNumber * number =  [self objectForString: key];
    return [number boolValue];
}

@end
