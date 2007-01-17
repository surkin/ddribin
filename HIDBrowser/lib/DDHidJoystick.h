//
//  DDHidJoystick.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHidDevice.h"

@class DDHidElement;
@class DDHidQueue;

@interface DDHidJoystick : DDHidDevice
{
    NSMutableArray * mButtonElements;

    DDHidQueue * mQueue;
    id mDelegate;
}

+ (NSArray *) allJoysticks;

- (id) initWithDevice: (io_object_t) device;

#pragma mark -
#pragma mark Mouse Elements

- (NSArray *) buttonElements;

- (unsigned) numberOfButtons;

- (void) addElementsToQueue: (DDHidQueue *) queue;

#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;

- (void) startListening;

- (void) stopListening;

@end

@interface NSObject (DDHidJoystickDelegate)

- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;

@end
