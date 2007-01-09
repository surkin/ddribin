//
//  HidBrowserController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HidBrowserController.h"
#import "DDHidDevice.h"

@implementation HidBrowserController

- (void) awakeFromNib
{
    [self willChangeValueForKey: @"devices"];
    mDevices = [[DDHidDevice allDevices] retain];
    [self didChangeValueForKey: @"devices"];
    NSDictionary * properties = [[mDevices objectAtIndex: 1] properties];
    NSArray * elements =  [properties objectForKey: @"Elements"];
    NSLog(@"Elements: %d, %@", [elements count], [elements class]);
    // NSDictionary * subElements = [elements objectForKey: @"Elements"];
    // NSLog(@"Subelements: %d", [subElements count]);
}

//=========================================================== 
// - devices
//=========================================================== 
- (NSArray *) devices
{
    return mDevices; 
}


@end
