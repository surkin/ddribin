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
#import "DDHidUsage.h"

@interface WatcherEvent : NSObject
{
    NSString * mUsageDescription;
    DDHidEvent * mEvent;
    int mIndex;
}

- (id) initWithUsageDescription: (NSString *) anUsageDecription 
                          event: (DDHidEvent *) anEvent
                          index: (int) index;

- (NSString *) usageDescription;
- (DDHidEvent *) event;

@end

@implementation WatcherEvent : NSObject

- (id) initWithUsageDescription: (NSString *) anUsageDescription 
                          event: (DDHidEvent *) anEvent
                          index: (int) index
{
    if (self = [super init])
    {
        mUsageDescription = [anUsageDescription retain];
        mEvent = [anEvent retain];
        mIndex = index;
    }
    return self;
}

//=========================================================== 
// - usageDescription
//=========================================================== 
- (NSString *) usageDescription
{
    return mUsageDescription; 
}

//=========================================================== 
// - event
//=========================================================== 
- (DDHidEvent *) event
{
    return mEvent; 
}

//=========================================================== 
// - index
//=========================================================== 
- (int) index
{
    return mIndex;
}

@end

@implementation WatcherWindowController

- (id) init
{
    self = [super initWithWindowNibName: @"EventWatcher" owner: self];
    if (self == nil)
        return nil;
    
    mEventHistory = [[NSMutableArray alloc] init];
    mNextIndex = 1;
    
    return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mQueue release];
    [mDevice release];
    [mElements release];
    [mEventHistory release];
    
    mQueue = nil;
    mDevice = nil;
    mElements = nil;
    mEventHistory = nil;
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mQueue release];
    mQueue = nil;
    [mDevice close];
    [self autorelease];
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow: sender];
}

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    WatcherEvent * watcherEvent;
    watcherEvent =
        [[WatcherEvent alloc] initWithUsageDescription: @"-----------------------------"
                                                 event: nil
                                                 index: mNextIndex++];
    [watcherEvent autorelease];
    [mEventHistoryController addObject: watcherEvent];

    NSMutableArray * newEvents = [NSMutableArray array];
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        DDHidElement * element = [mDevice elementForCookie: [event elementCookie]];
        watcherEvent =
            [[WatcherEvent alloc] initWithUsageDescription: [[element usage] usageNameWithIds]
                                                     event: event
                                                     index: mNextIndex++];
        [watcherEvent autorelease];
        [newEvents addObject: watcherEvent];
    }
    [mEventHistoryController addObjects: newEvents];
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

//=========================================================== 
//  eventHistory 
//=========================================================== 
- (NSMutableArray *) eventHistory
{
    return mEventHistory; 
}

- (void) setEventHistory: (NSMutableArray *) anEventHistory
{
    if (mEventHistory != anEventHistory)
    {
        [mEventHistory release];
        mEventHistory = [anEventHistory retain];
    }
}
- (void) addToEventHistory: (id)mEventHistoryObject
{
    [[self eventHistory] addObject: mEventHistoryObject];
}
- (void) removeFromEventHistory: (id)mEventHistoryObject
{
    [[self eventHistory] removeObject: mEventHistoryObject];
}

@end
