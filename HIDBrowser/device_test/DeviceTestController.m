//
//  DeviceTestController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DeviceTestController.h"
#import "DDHidMouse.h"
#import "DDHidQueue.h"
#import "DDHidEvent.h"
#import "DDHidElement.h"
#import "DDHidUsage.h"


@implementation DeviceTestController

static DDHidMouse * mDevice;

- (void) addCookiesToQueue: (DDHidMouse *) mouse;
{
    [mQueue addElement: [mouse XElement]];
    [mQueue addElement: [mouse YElement]];
    [mQueue addElements: [mouse buttonElements]];
}

- (void) awakeFromNib;
{
    NSLog(@"DeviceTestController");
    NSArray * mice = [DDHidMouse allMice];
    NSLog(@"All mice: %@", mice);
    NSEnumerator * e = [mice objectEnumerator];
    DDHidMouse * mouse;
    while (mouse = [e nextObject])
    {
        NSLog(@"Product name: %@, location: 0x%08X, product: 0x%08X, vendor: 0x%08X",
              [mouse productName], [mouse locationId], [mouse productId], [mouse vendorId]);
        
    }
    [self setMice: mice];
    mDevice = [mMice objectAtIndex: 0];
    mQueue = [[mDevice createQueueWithSize: 30] retain];
    [mQueue setDelegate: self];
    [self addCookiesToQueue: mDevice];
    [mQueue startOnCurrentRunLoop];
}

//=========================================================== 
//  mice 
//=========================================================== 
- (NSArray *) mice
{
    return mMice; 
}

- (void) setMice: (NSArray *) theMice
{
    if (mMice != theMice)
    {
        [mMice release];
        mMice = [theMice retain];
    }
}

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        DDHidElement * element = [mDevice elementForCookie: [event elementCookie]];
        NSLog(@"Element: %@, value: %d", [[element usage] usageName], [event value]);
    }
}

@end
