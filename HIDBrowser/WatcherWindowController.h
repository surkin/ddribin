//
//  WatcherWindowController.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHidDevice.h"
#import "DDHidElement.h"

@class DDHidQueue;

@interface WatcherWindowController : NSWindowController
{
    DDHidDevice * mDevice;
    NSArray * mElements;
    DDHidQueue * mQueue;
}

- (DDHidDevice *) device;
- (void) setDevice: (DDHidDevice *) newDevice;

- (NSArray *) elements;
- (void) setElements: (NSArray *) newElements;

@end
