//
//  DDHidMouse.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidMouse.h"
#import "DDHidUsage.h"
#import "DDHidElement.h"
#import "DDHidQueue.h"
#import "DDHidEvent.h"
#include <IOKit/hid/IOHIDUsageTables.h>


@interface DDHidMouse (Private)

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;

@end

@implementation DDHidMouse

+ (NSArray *) allMice;
{
    return
        [DDHidDevice allDevicesMatchingUsagePage: kHIDPage_GenericDesktop
                                         usageId: kHIDUsage_GD_Mouse
                                       withClass: self];
}

- (void) initMouseElements: (NSArray *) elements;
{
    NSEnumerator * e = [elements objectEnumerator];
    DDHidElement * element;
    while (element = [e nextObject])
    {
        unsigned usagePage = [[element usage] usagePage];
        unsigned usageId = [[element usage] usageId];
        if ((usagePage == kHIDPage_GenericDesktop) &&
            (usageId == kHIDUsage_GD_X))
        {
            mXElement = [element retain];
        }
        else if ((usagePage == kHIDPage_GenericDesktop) &&
                 (usageId == kHIDUsage_GD_Y))
        {
            mYElement = [element retain];
        }
        else if ((usagePage == kHIDPage_GenericDesktop) &&
                 (usageId == kHIDUsage_GD_Wheel))
        {
            mWheelElement = [element retain];
        }
        else if ((usagePage == kHIDPage_Button) &&
                 (usageId > 0))
        {
            [mButtonElements addObject: element];
        }
        NSArray * subElements = [element elements];
        if (subElements != nil)
            [self initMouseElements: subElements];
    }
}

- (id) initWithDevice: (io_object_t) device;
{
    self = [super initWithDevice: device];
    if (self == nil)
        return nil;
    
    mButtonElements = [[NSMutableArray alloc] init];
    NSArray * elements = [self elements];
    [self initMouseElements: elements];
    
    NSLog(@"X: %@, Y: %@, buttons: %@", mXElement, mYElement, mButtonElements);
    
    return self;
}

#pragma mark -
#pragma mark Mouse Elements

//=========================================================== 
// - xElement
//=========================================================== 
- (DDHidElement *) xElement
{
    return mXElement; 
}

//=========================================================== 
// - yElement
//=========================================================== 
- (DDHidElement *) yElement
{
    return mYElement; 
}

- (DDHidElement *) wheelElement;
{
    return mWheelElement;
}

//=========================================================== 
// - buttonElements
//=========================================================== 
- (NSArray *) buttonElements;
{
    return mButtonElements; 
}

- (unsigned) numberOfButtons;
{
    return [mButtonElements count];
}

- (void) addElementsToQueue: (DDHidQueue *) queue;
{
    [queue addElement: mXElement];
    [queue addElement: mYElement];
    [queue addElement: mWheelElement];
    [queue addElements: mButtonElements];
}


#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;
{
    mDelegate = delegate;
}

- (void) startListening;
{
    if (mQueue != nil)
        return;
    
    mQueue = [[self createQueueWithSize: 10] retain];
    [mQueue setDelegate: self];
    [self addElementsToQueue: mQueue];
    [mQueue startOnCurrentRunLoop];
}

- (void) stopListening;
{
    if (mQueue == nil)
        return;
    
    [mQueue stop];
    [mQueue release];
    mQueue = nil;
}

@end

@implementation DDHidMouse (Private)

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        IOHIDElementCookie cookie = [event elementCookie];
        SInt32 value = [event value];
        if (cookie == [[self xElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:xChanged:)])
            {
                [mDelegate hidMouse: self xChanged: value];
            }
        }
        else if (cookie == [[self yElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:yChanged:)])
            {
                [mDelegate hidMouse: self yChanged: value];
            }
        }
        else if (cookie == [[self wheelElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:wheelChanged:)])
            {
                [mDelegate hidMouse: self wheelChanged: value];
            }
        }
        else
        {
            unsigned i = 0;
            for (i = 0; i < [[self buttonElements] count]; i++)
            {
                if (cookie == [[[self buttonElements] objectAtIndex: i] cookie])
                    break;
            }
            
            if ((value == 1) &&
                [mDelegate respondsToSelector: @selector(hidMouse:buttonDown:)])
            {
                [mDelegate hidMouse: self buttonDown: i];
            }
            else if ((value == 0) &&
                     [mDelegate respondsToSelector: @selector(hidMouse:buttonUp:)])
            {
                [mDelegate hidMouse: self buttonUp: i];
            }
            else
            {
                DDHidElement * element = [self elementForCookie: [event elementCookie]];
                NSLog(@"Element: %@, value: %d", [[element usage] usageName], [event value]);
            }
        }
    }
}

@end
