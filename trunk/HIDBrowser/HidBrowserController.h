//
//  HidBrowserController.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HidBrowserController : NSObject
{
    IBOutlet NSArrayController * mDevicesController;
    IBOutlet NSTreeController * mElementsController;
    NSArray * mDevices;
}

- (NSArray *) devices;

- (IBAction) press: (id) sender;

@end
