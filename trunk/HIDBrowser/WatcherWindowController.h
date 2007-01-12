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
    IBOutlet NSArrayController * mEventHistoryController;
    DDHidDevice * mDevice;
    NSArray * mElements;
    DDHidQueue * mQueue;
    NSMutableArray * mEventHistory;
    int mNextSerialNumber;
}

- (DDHidDevice *) device;
- (void) setDevice: (DDHidDevice *) newDevice;

- (NSArray *) elements;
- (void) setElements: (NSArray *) newElements;

- (NSMutableArray *) eventHistory;
- (void) setEventHistory: (NSMutableArray *) anEventHistory;
- (void) addToEventHistory: (id)mEventHistoryObject;
- (void) removeFromEventHistory: (id)mEventHistoryObject;

@end
