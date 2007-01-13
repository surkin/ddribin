//
//  DDHidUsage.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidUsage.h"
#import "DDHidUsageTables.h"

@implementation DDHidUsage

+ (DDHidUsage *) usageWithUsagePage: (unsigned) usagePage
                            usageId: (unsigned) usageId;
{
    return [[[self alloc] initWithUsagePage: usagePage usageId: usageId]
        autorelease];
}

- (id) initWithUsagePage: (unsigned) usagePage
                 usageId: (unsigned) usageId;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUsagePage = usagePage;
    mUsageId = usageId;
    
    return self;
}

- (unsigned) usagePage;
{
    return mUsagePage;
}

- (unsigned) usageId;
{
    return mUsageId;
}

- (NSString *) usageName;
{
    DDHidUsageTables * usageTables = [DDHidUsageTables standardUsageTables];
    return
        [usageTables descriptionForUsagePage: mUsagePage
                                       usage: mUsageId];
}

- (NSString *) usageNameWithIds;
{
    return [NSString stringWithFormat: @"%@ (0x%04x : 0x%04x)",
        [self usageName], mUsagePage, mUsageId];
}

- (NSString *) description;
{
    return [NSString stringWithFormat: @"HID Usage: %@", [self usageName]];
}

@end
