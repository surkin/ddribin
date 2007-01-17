//
//  JoystickPaneController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "JoystickPaneController.h"
#import "DDHidJoystick.h"

@interface JoystickPaneController (Private)

- (void) setJoysticks: (NSArray *) theJoysticks;

@end

@implementation JoystickPaneController

- (void) awakeFromNib;
{
    NSArray * joysticks = [DDHidJoystick allJoysticks];

    NSEnumerator * e = [joysticks objectEnumerator];
    DDHidJoystick * joystick;
    while (joystick = [e nextObject])
    {
        [joystick setDelegate: self];
        NSLog(@"Joystick product name: %@",
              [joystick productName]);
    }
    [self setJoysticks: joysticks];
    joystick = [mJoysticks objectAtIndex: 0];
    [joystick startListening];
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

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
{
    NSLog(@"Joystick button #%d down", buttonNumber);
}

- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;
{
    NSLog(@"Joystick button #%d up", buttonNumber);
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
