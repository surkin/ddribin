//
//  DDHidJoystick.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidLib.h"
#include <IOKit/hid/IOHIDUsageTables.h>

@interface DDHidJoystick (DDHidJoystickDelegate)

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;

@end

@interface DDHidJoystick (Private)

- (void) initJoystickElements: (NSArray *) elements;
- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;

@end

@implementation DDHidJoystick

+ (NSArray *) allJoysticks;
{
    return
        [DDHidDevice allDevicesMatchingUsagePage: kHIDPage_GenericDesktop
                                         usageId: kHIDUsage_GD_Joystick
                                       withClass: self];
}

- (id) initWithDevice: (io_object_t) device;
{
    self = [super initWithDevice: device];
    if (self == nil)
        return nil;
    
    mButtonElements = [[NSMutableArray alloc] init];
    [self initJoystickElements: [self elements]];
    mQueue = nil;
    mDelegate = nil;
    
    return self;
}

#pragma mark -
#pragma mark Mouse Elements

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

@implementation DDHidJoystick (Private)

- (void) initJoystickElements: (NSArray *) elements;
{
    NSEnumerator * e = [elements objectEnumerator];
    DDHidElement * element;
    while (element = [e nextObject])
    {
        unsigned usagePage = [[element usage] usagePage];
        unsigned usageId = [[element usage] usageId];
#if 0
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
        else
#endif
            if ((usagePage == kHIDPage_Button) &&
                 (usageId > 0))
        {
            [mButtonElements addObject: element];
        }
        NSArray * subElements = [element elements];
        if (subElements != nil)
            [self initJoystickElements: subElements];
    }
}

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        IOHIDElementCookie cookie = [event elementCookie];
        SInt32 value = [event value];
#if 0
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
#endif
        {
            unsigned i = 0;
            for (i = 0; i < [[self buttonElements] count]; i++)
            {
                if (cookie == [[[self buttonElements] objectAtIndex: i] cookie])
                    break;
            }
            
            if (value == 1)
            {
                [self hidJoystick: self buttonDown: i];
            }
            else if (value == 0)
            {
                [self hidJoystick: self buttonUp: i];
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

@implementation DDHidJoystick (DDHidJoystickDelegate)

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
{
    if ([mDelegate respondsToSelector: _cmd])
        [mDelegate hidJoystick: joystick buttonDown: buttonNumber];
}

- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;  
{
    if ([mDelegate respondsToSelector: _cmd])
        [mDelegate hidJoystick: joystick buttonUp: buttonNumber];
}

@end

