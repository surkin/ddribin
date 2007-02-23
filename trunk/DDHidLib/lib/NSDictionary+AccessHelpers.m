//
//  NSDictionary+AccessHelpers.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+AccessHelpers.h"


@implementation NSDictionary (AccessHelpers)

- (unsigned) ddhid_unsignedForKey: (NSString *) key;
{
    NSNumber * number = [self objectForKey: key];
    return [number unsignedIntValue];
}

- (id) ddhid_objectForString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithCString: key];
    return [self objectForKey: objcKey];
}

- (NSString *) ddhid_stringForString: (const char *) key;
{
    return [self ddhid_objectForString: key];
}

- (long) ddhid_longForString: (const char *) key;
{
    NSNumber * number =  [self ddhid_objectForString: key];
    return [number longValue];
}

- (unsigned int) ddhid_unsignedIntForString: (const char *) key;
{
    NSNumber * number =  [self ddhid_objectForString: key];
    return [number unsignedIntValue];
}

- (BOOL) ddhid_boolForString: (const char *) key;
{
    NSNumber * number =  [self ddhid_objectForString: key];
    return [number boolValue];
}

@end

@implementation NSMutableDictionary (AccessHelpers)

- (void) ddhid_setObject: (id) object forString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithCString: key];
    [self setObject: object forKey: objcKey];
}

@end