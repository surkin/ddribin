//
//  JoystickPaneController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "JoystickPaneController.h"
#import "DDHidJoystick.h"
#import "ButtonState.h"

@interface JoystickPaneController (Private)

- (void) setJoysticks: (NSArray *) theJoysticks;

@end

@implementation JoystickPaneController

- (void) awakeFromNib;
{
    NSArray * joysticks = [DDHidJoystick allJoysticks];

    mJoystickButtons = [[NSMutableArray alloc] init];
    NSEnumerator * e = [joysticks objectEnumerator];
    DDHidJoystick * joystick;
    while (joystick = [e nextObject])
    {
        [joystick setDelegate: self];
        NSLog(@"Joystick product name: %@",
              [joystick productName]);
    }
    [self setJoysticks: joysticks];
    if ([mJoysticks count] > 0)
        [self setJoystickIndex: 0];
    else
        [self setJoystickIndex: NSNotFound];
}

//=========================================================== 
//  joysticks 
//=========================================================== 
- (NSArray *) joysticks
{
    return mJoysticks; 
}

- (NSArray *) joystickButtons;
{
    return mJoystickButtons;
}

//=========================================================== 
//  joystickIndex 
//=========================================================== 
- (unsigned) joystickIndex
{
    return mJoystickIndex;
}

- (void) setJoystickIndex: (unsigned) theJoystickIndex
{
    if (mCurrentJoystick != nil)
    {
        [mCurrentJoystick stopListening];
        mCurrentJoystick = nil;
    }
    mJoystickIndex = theJoystickIndex;
    [mJoysticksController setSelectionIndex: mJoystickIndex];
    if (mJoystickIndex != NSNotFound)
    {
        mCurrentJoystick = [mJoysticks objectAtIndex: mJoystickIndex];
        [mCurrentJoystick startListening];
        
        [self willChangeValueForKey: @"joystickButtons"];
        [mJoystickButtons removeAllObjects];
        NSArray * buttons = [mCurrentJoystick buttonElements];
        NSEnumerator * e = [buttons objectEnumerator];
        DDHidElement * element;
        while (element = [e nextObject])
        {
            ButtonState * state = [[ButtonState alloc] initWithName: [[element usage] usageName]];
            [state autorelease];
            [mJoystickButtons addObject: state];
        }
        [self didChangeValueForKey: @"joystickButtons"];
    }
}

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
{
    ButtonState * state = [mJoystickButtons objectAtIndex: buttonNumber];
    [state setPressed: YES];
}

- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;
{
    ButtonState * state = [mJoystickButtons objectAtIndex: buttonNumber];
    [state setPressed: NO];
}

@end

@implementation JoystickPaneController (Private)

- (void) setJoysticks: (NSArray *) theJoysticks
{
    if (mJoysticks != theJoysticks)
    {
        [mJoysticks release];
        mJoysticks = [theJoysticks retain];
    }
}

@end
