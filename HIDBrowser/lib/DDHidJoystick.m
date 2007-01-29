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

- (void) hidJoystick: (DDHidJoystick *)  joystick
            xChanged: (int) value
             ofStick: (unsigned) stick;
- (void) hidJoystick: (DDHidJoystick *)  joystick
            yChanged: (int) value
             ofStick: (unsigned) stick;
- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;

@end

@interface DDHidJoystick (Private)

- (void) initJoystickElements: (NSArray *) elements;
- (void) addStick: (NSArray *) stickElements;
- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;

- (BOOL) findStick: (unsigned *) stick
           element: (DDHidElement **) elementOut
   withXAxisCookie: (IOHIDElementCookie) cookie;
- (BOOL) findStick: (unsigned *) stick
           element: (DDHidElement **) elementOut
   withYAxisCookie: (IOHIDElementCookie) cookie;
- (BOOL) findOtherAxis: (unsigned *) otherAxis
               onStick: (unsigned *) stick
            withCookie: (IOHIDElementCookie) cookie;

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
    mSticks = [[NSMutableArray alloc] init];
    [self initJoystickElements: [self elements]];
    mQueue = nil;
    mDelegate = nil;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mQueue release];
    [mSticks release];
    [mButtonElements release];
    
    mQueue = nil;
    mSticks = nil;
    mButtonElements = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Joystick Elements

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

#pragma mark -
#pragma mark Sticks - indexed accessors

- (unsigned int) countOfSticks 
{
    return [mSticks count];
}

- (DDHidJoystickStick *) objectInSticksAtIndex: (unsigned int)index 
{
    return [mSticks objectAtIndex: index];
}

- (void) addElementsToQueue: (DDHidQueue *) queue;
{
    NSEnumerator * e = [mSticks objectEnumerator];
    DDHidJoystickStick * stick;
    while (stick = [e nextObject])
    {
        [queue addElements: [stick allElements]];
    }
    
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
    DDHidJoystickStick * currentStick = [[[DDHidJoystickStick alloc] init] autorelease];
    while (element = [e nextObject])
    {
        unsigned usagePage = [[element usage] usagePage];
        unsigned usageId = [[element usage] usageId];
        NSArray * subElements = [element elements];
        
        if ((usagePage == kHIDPage_GenericDesktop) &&
            (usageId == kHIDUsage_GD_Pointer))
        {
            [self addStick: subElements];
        }
        else if ((usagePage == kHIDPage_GenericDesktop) &&
            (usageId == kHIDUsage_GD_X))
        {
            [currentStick addElement: element];
        }
        else if ((usagePage == kHIDPage_GenericDesktop) &&
                 (usageId == kHIDUsage_GD_Y))
        {
            [currentStick addElement: element];
        }
#if 0
        else if ((usagePage == kHIDPage_GenericDesktop) &&
                 (usageId == kHIDUsage_GD_Wheel))
        {
            mWheelElement = [element retain];
        }
        else
#endif
        else if ((usagePage == kHIDPage_Button) &&
                 (usageId > 0))
        {
            [mButtonElements addObject: element];
        }
        if (subElements != nil)
            [self initJoystickElements: subElements];
    }
    if ([currentStick countOfStickElements] > 0)
    {
        [mSticks addObject: currentStick];
    }
}

- (void) addStick: (NSArray *) elements;
{
    NSEnumerator * e = [elements objectEnumerator];
    DDHidElement * element;
    while (element = [e nextObject])
    {
        NSLog(@"Stick element: %@", [[element usage] usageName]);
    }
}

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        IOHIDElementCookie cookie = [event elementCookie];
        SInt32 value = [event value];
        DDHidElement * element;
        unsigned stick;
        // unsigned otherAxis;
        if ([self findStick: &stick element: &element withXAxisCookie: cookie])
        {
            int normalizedValue = (((value - [element minValue]) * 65536) /
                                   ([element maxValue] - [element minValue] + 1)) - 32768;
            [self hidJoystick: self xChanged: normalizedValue ofStick: stick];
        }
        else if ([self findStick: &stick element: &element withYAxisCookie: cookie])
        {
            int normalizedValue = (((value - [element minValue]) * 65536) /
                                   ([element maxValue] - [element minValue] + 1)) - 32768;
            [self hidJoystick: self yChanged: normalizedValue ofStick: stick];
        }
#if 0
        else if (cookie == [[self wheelElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:wheelChanged:)])
            {
                [mDelegate hidMouse: self wheelChanged: value];
            }
        }
#endif
        else
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

- (BOOL) findStick: (unsigned *) stick
           element: (DDHidElement **) elementOut
   withXAxisCookie: (IOHIDElementCookie) cookie;
{
    unsigned i;
    for (i = 0; i < [mSticks count]; i++)
    {
        DDHidElement * element = [[mSticks objectAtIndex: i] xAxisElement];
        if ((element != nil) && ([element cookie] == cookie))
        {
            *stick = i;
            *elementOut = element;
            return YES;
        }
    }
    return NO;
}

- (BOOL) findStick: (unsigned *) stick
           element: (DDHidElement **) elementOut
   withYAxisCookie: (IOHIDElementCookie) cookie;
{
    unsigned i;
    for (i = 0; i < [mSticks count]; i++)
    {
        DDHidElement * element = [[mSticks objectAtIndex: i] yAxisElement];
        if ((element != nil) && ([element cookie] == cookie))
        {
            *stick = i;
            *elementOut = element;
            return YES;
        }
    }
    return NO;
}

- (BOOL) findOtherAxis: (unsigned *) otherAxis
               onStick: (unsigned *) stick
            withCookie: (IOHIDElementCookie) cookie;
{
    return NO;
}

@end

@implementation DDHidJoystick (DDHidJoystickDelegate)

- (void) hidJoystick: (DDHidJoystick *)  joystick
            xChanged: (int) value
             ofStick: (unsigned) stick;
{
    if ([mDelegate respondsToSelector: _cmd])
        [mDelegate hidJoystick: joystick xChanged: value ofStick: stick];
}

- (void) hidJoystick: (DDHidJoystick *)  joystick
            yChanged: (int) value
             ofStick: (unsigned) stick;
{
    if ([mDelegate respondsToSelector: _cmd])
        [mDelegate hidJoystick: joystick yChanged: value ofStick: stick];
}

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

@implementation DDHidJoystickStick

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mStickElements = [[NSMutableArray alloc] init];
    mXAxisElement = nil;
    mYAxisElement = nil;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mStickElements release];
    [mXAxisElement release];
    [mYAxisElement release];
    
    mStickElements = nil;
    mXAxisElement = nil;
    mYAxisElement = nil;
    [super dealloc];
}

-  (void) addElement: (DDHidElement *) element;
{
    [mStickElements addObject: element];
    DDHidUsage * usage = [element usage];
    BOOL isXAxis = [usage isEqualToUsagePage: kHIDPage_GenericDesktop
                                     usageId: kHIDUsage_GD_X];
    BOOL isYAxis = [usage isEqualToUsagePage: kHIDPage_GenericDesktop
                                     usageId: kHIDUsage_GD_Y];
    if (isXAxis && (mXAxisElement == nil))
        mXAxisElement = [element retain];
    if (isYAxis && (mYAxisElement == nil))
        mYAxisElement = [element retain];
}

- (NSArray *) allElements;
{
    NSMutableArray * elements = [NSMutableArray array];
    if (mXAxisElement != nil)
        [elements addObject: mXAxisElement];
    if (mYAxisElement != nil)
        [elements addObject: mYAxisElement];
    [elements addObjectsFromArray: mStickElements];
    return elements;
}

#pragma mark -
#pragma mark mStickElements - indexed accessors

- (unsigned int) countOfStickElements 
{
    return [mStickElements count];
}

- (DDHidElement *) objectInStickElementsAtIndex: (unsigned int)index 
{
    return [mStickElements objectAtIndex: index];
}

- (DDHidElement *) xAxisElement;
{
    return mXAxisElement;
}

- (DDHidElement *) yAxisElement;
{
    return mYAxisElement;
}

- (NSString *) description;
{
    return [mStickElements description];
}

@end
