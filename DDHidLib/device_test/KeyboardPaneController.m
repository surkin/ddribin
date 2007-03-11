//
//  KeyboardPaneController.m
//  DDHidLib
//
//  Created by Dave Dribin on 3/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "KeyboardPaneController.h"
#import "DDHidLib.h"
#include <IOKit/hid/IOHIDUsageTables.h>

@interface KeyboardPaneController (Private)

- (void) addEvent: (NSString *) event usageId: (unsigned) usageId;

@end

@implementation KeyboardPaneController

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mEvents = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) awakeFromNib;
{
    NSArray * keyboards = [DDHidKeyboard allKeyboards];
    NSEnumerator * e = [keyboards objectEnumerator];
    DDHidKeyboard * keyboard;
    while (keyboard = [e nextObject])
    {
        [keyboard setDelegate: self];
    }

    [self setKeyboards: keyboards];
    
    if ([keyboards count] > 0)
        [self setKeyboardIndex: 0];
    else
        [self setKeyboardIndex: NSNotFound];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mKeyboards release];
    [mEvents release];
    
    mKeyboards = nil;
    mEvents = nil;
    [super dealloc];
}

//=========================================================== 
//  keyboards 
//=========================================================== 
- (NSArray *) keyboards
{
    return mKeyboards; 
}

- (void) setKeyboards: (NSArray *) theKeyboards
{
    if (mKeyboards != theKeyboards)
    {
        [mKeyboards release];
        mKeyboards = [theKeyboards retain];
    }
}
//=========================================================== 
//  keyboardIndex 
//=========================================================== 
- (unsigned) keyboardIndex
{
    return mKeyboardIndex;
}

- (void) setKeyboardIndex: (unsigned) theKeyboardIndex
{
    if (mCurrentKeyboard != nil)
    {
        [mCurrentKeyboard stopListening];
        mCurrentKeyboard = nil;
    }
    mKeyboardIndex = theKeyboardIndex;
    [mKeyboardsController setSelectionIndex: mKeyboardIndex];
    [self willChangeValueForKey: @"events"];
    [mEvents removeAllObjects];
    [self didChangeValueForKey: @"events"];
    if (mKeyboardIndex != NSNotFound)
    {
        mCurrentKeyboard = [mKeyboards objectAtIndex: mKeyboardIndex];
        [mCurrentKeyboard startListening];
    }
}

//=========================================================== 
//  events 
//=========================================================== 
- (NSMutableArray *) events
{
    return mEvents; 
}

- (void) setEvents: (NSMutableArray *) theEvents
{
    if (mEvents != theEvents)
    {
        [mEvents release];
        mEvents = [theEvents retain];
    }
}
- (void) addEvent: (id)theEvent
{
    [[self events] addObject: theEvent];
}
- (void) removeEvent: (id)theEvent
{
    [[self events] removeObject: theEvent];
}


@end

@implementation KeyboardPaneController (DDHidKeyboardDelegate)

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
               keyDown: (unsigned) usageId;
{
    [self addEvent: @"Key Down" usageId: usageId];
}

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
                 keyUp: (unsigned) usageId;
{
    [self addEvent: @"Key Up" usageId: usageId];
}

@end

@implementation KeyboardPaneController (Private)

- (void) addEvent: (NSString *) event usageId: (unsigned) usageId;
{
    DDHidUsageTables * usageTables = [DDHidUsageTables standardUsageTables];
    NSString * description =
        [usageTables descriptionForUsagePage: kHIDPage_KeyboardOrKeypad
                                       usage: usageId];
    
    NSMutableDictionary * row = [mKeyboardEventsController newObject];
    [row setObject: event forKey: @"event"];
    [row setObject: description forKey: @"description"];
    [mKeyboardEventsController addObject: row];
}

@end

