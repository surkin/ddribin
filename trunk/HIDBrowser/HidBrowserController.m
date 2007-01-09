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
    NSArray * devices = [DDHidDevice allDevices];
    NSLog(@"Devices:");
    NSEnumerator * e = [devices objectEnumerator];
    DDHidDevice * device;
    while (device = [e nextObject])
    {
        NSLog(@"Name: %@", [device productName]);
        NSLog(@"Manufacturer: %@, transport: %@", [device manufacturer],
              [device transport]);
        NSLog(@"Vendor ID: %ld, product ID: %ld, version: %ld",
              [device vendorId], [device productId], [device version]);
    }

    [self willChangeValueForKey: @"devices"];
    mDevices = [devices retain];
    [self didChangeValueForKey: @"devices"];
}

//=========================================================== 
// - devices
//=========================================================== 
- (NSArray *) devices
{
    return mDevices; 
}


@end
