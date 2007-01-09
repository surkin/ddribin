//
//  DDHidUsageTables.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidUsageTables.h"

@implementation DDHidUsageTables

static DDHidUsageTables * sStandardUsageTables = nil;

+ (DDHidUsageTables *) standardUsageTables;
{
    if (sStandardUsageTables == nil)
    {
        NSBundle * myBundle = [NSBundle bundleForClass: self];
        NSString * usageTablesPath =
            [myBundle pathForResource: @"usb_hid_usages" ofType: @"plist"];
        NSDictionary * lookupTables =
            [NSDictionary dictionaryWithContentsOfFile: usageTablesPath];
        sStandardUsageTables =
            [[DDHidUsageTables alloc] initWithLookupTables: lookupTables];
        [sStandardUsageTables retain];
    }
    
    return sStandardUsageTables;
}

- (id) initWithLookupTables: (NSDictionary *) lookupTables;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mLookupTables = [lookupTables retain];
    
    return self;
}

- (NSString *) descriptionForUsagePage: (unsigned) usagePage
                                usage: (unsigned) usage
{
    NSString * usagePageString = [NSString stringWithFormat: @"%u", usagePage];
    NSString * usageString = [NSString stringWithFormat: @"%u", usage];
    // NSNumber * usagePageNumber = [NSNumber numberWithUnsignedInt: usagePage];
    
    NSDictionary * usagePageLookup = [mLookupTables objectForKey: usagePageString];
    if (usagePageLookup == nil)
        return @"Unknown usage page";
    
    NSDictionary * usageLookup = [usagePageLookup objectForKey: @"usages"];
    NSString * description = [usageLookup objectForKey: usageString];
    if (description != nil)
        return description;
    
    NSString * defaultUsage = [usagePageLookup objectForKey: @"default"];
    if (defaultUsage != nil)
    {
        description = [NSString stringWithFormat: defaultUsage, usage];
        return description;
    }
    
    return @"Unknown usage";
}

@end
