//
//  DeviceTestController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DeviceTestController.h"


@implementation DeviceTestController

- (void) awakeFromNib
{
    [mWindow center];
    [mWindow makeKeyAndOrderFront: self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
