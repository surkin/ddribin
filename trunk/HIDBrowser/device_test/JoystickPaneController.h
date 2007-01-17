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
    NSArray * mJoysticks;
    NSMutableArray * mJoystickButtons;
}

- (NSArray *) joysticks;

- (NSArray *) joystickButtons;

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;

@end
