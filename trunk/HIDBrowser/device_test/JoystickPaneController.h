//
//  JoystickPaneController.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHidLib.h"


@interface JoystickPaneController : NSObject
{
    IBOutlet NSArrayController * mJoysticksController;

    NSArray * mJoysticks;
    NSMutableArray * mJoystickButtons;
    unsigned mJoystickIndex;

    // Don't retain these
    DDHidJoystick * mCurrentJoystick;
}

- (NSArray *) joysticks;

- (NSArray *) joystickButtons;

- (unsigned) joystickIndex;
- (void) setJoystickIndex: (unsigned) theJoystickIndex;

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;

@end
