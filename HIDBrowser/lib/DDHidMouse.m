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
#include <IOKit/hid/IOHIDUsageTables.h>


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

@end
