//
//  WatcherWindowController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WatcherWindowController.h"
#import "DDHidQueue.h"
#import "DDHidEvent.h"

@implementation WatcherWindowController

- (id) init
{
    self = [super initWithWindowNibName: @"EventWatcher" owner: self];
    if (self == nil)
        return nil;
    
    return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mDevice release];
    [mElements release];
    
    mDevice = nil;
    mElements = nil;
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
    fprintf(stderr, "windowWillClose");
    [mQueue release];
    [mDevice close];
    [self autorelease];
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow: sender];
}

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        DDHidElement * element = [mDevice elementForCookie: [event elementCookie]];
        NSLog(@"Element: %@, cookie: %d, value: %d, longValue: %d",
              [element usageDescription],
              [event elementCookie], [event value], [event longValue]);
    }
}

- (void) addCookiesToQueue;
{
    NSEnumerator * e = [mElements objectEnumerator];
    DDHidElement * element;
    while(element = [e nextObject])
    {
        [mQueue addElement: element];
    }
}

- (void) windowDidLoad;
{
    [mDevice open];
    mQueue = [[mDevice createQueueWithSize: 12] retain];
    [mQueue setDelegate: self];
    [self addCookiesToQueue];
    [mQueue startOnCurrentRunLoop];
}

//=========================================================== 
//  device 
//=========================================================== 
- (DDHidDevice *) device
{
    return [[mDevice retain] autorelease]; 
}

- (void) setDevice: (DDHidDevice *) newDevice
{
    if (mDevice != newDevice)
    {
        [mDevice release];
        mDevice = [newDevice retain];
    }
}

//=========================================================== 
//  elements 
//=========================================================== 
- (NSArray *) elements
{
    return [[mElements retain] autorelease]; 
}

- (void) setElements: (NSArray *) newElements
{
    if (mElements != newElements)
    {
        [mElements release];
        mElements = [newElements retain];
    }
}


@end
