//
//  WatcherWindowController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WatcherWindowController.h"


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

static CFRunLoopSourceRef eventSource;

- (void)windowWillClose:(NSNotification *)notification
{
    fprintf(stderr, "windowWillClose");
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), eventSource, kCFRunLoopDefaultMode);
    (*mQueue)->stop(mQueue);
    (*mQueue)->dispose(mQueue);
    (*mQueue)->Release(mQueue);
    [mDevice close];
    [self autorelease];
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow: sender];
}

- (void) callback: (const IOHIDEventStruct *) event;
{
    DDHidElement * element = [mDevice elementForCookie: event->elementCookie];
    NSLog(@"Element: %@, cookie: %d, value: %d, longValue: %d",
          [element usageDescription],
          event->elementCookie, event->value, event->longValue);
}

/*	Callback method for the device queue
Will be called for any event of any type (cookie) to which we subscribe
*/
static void QueueCallbackFunction(void* target,  IOReturn result, void* refcon, void* sender)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    WatcherWindowController * controller = (WatcherWindowController *) target;

	IOHIDEventStruct event;	
	AbsoluteTime 	 zeroTime = {0,0};
	while (result == kIOReturnSuccess)
	{
		result = (*(controller->mQueue))->getNextEvent((controller->mQueue), &event, zeroTime, 0);		
		if ( result != kIOReturnSuccess )
			continue;
        
        [controller callback: &event];
	}
    [pool release];
}

- (void) addCookiesToQueue;
{
    NSEnumerator * e = [mElements objectEnumerator];
    DDHidElement * element;
    while(element = [e nextObject])
    {
        IOHIDElementCookie cookie = [element cookie];
        (*mQueue)->addElement(mQueue, cookie, 0);
    }
}

- (void) windowDidLoad;
{
    [mDevice open];
    IOHIDDeviceInterface122 ** deviceInterface = [mDevice deviceInterface];
    mQueue = (*deviceInterface)->allocQueue(deviceInterface);
    if (!mQueue)
        return;
    IOReturn ioReturnValue = (*mQueue)->create(mQueue, 0, 12);
    
    [self addCookiesToQueue];
    
    // add callback for async events
    ioReturnValue = (*mQueue)->createAsyncEventSource(mQueue, &eventSource);
    if (ioReturnValue == KERN_SUCCESS) {
        ioReturnValue = (*mQueue)->setEventCallout(mQueue,QueueCallbackFunction, self, NULL);
        if (ioReturnValue == KERN_SUCCESS) {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), eventSource, kCFRunLoopDefaultMode);					
            //start data delivery to queue
            (*mQueue)->start(mQueue);	
            return;
        } else {
            NSLog(@"Error when setting event callout");
        }
    } else {
        NSLog(@"Error when creating async event source");
    }
    
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
