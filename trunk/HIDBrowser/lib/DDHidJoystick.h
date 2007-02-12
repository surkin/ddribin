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

@interface DDHidJoystickStick : NSObject
{
    NSMutableArray * mStickElements;
    DDHidElement * mXAxisElement;
    DDHidElement * mYAxisElement;
}

#pragma mark -
#pragma mark mStickElements - indexed accessors

- (unsigned int) countOfStickElements;
- (DDHidElement *) objectInStickElementsAtIndex: (unsigned int)index;

- (DDHidElement *) xAxisElement;

- (DDHidElement *) yAxisElement;

- (NSArray *) allElements;

-  (void) addElement: (DDHidElement *) element;

@end

@interface DDHidJoystick : DDHidDevice
{
    DDHidQueue * mQueue;

    NSMutableArray * mSticks;
    NSMutableArray * mButtonElements;

    id mDelegate;
}

+ (NSArray *) allJoysticks;

- (id) initWithDevice: (io_object_t) device error: (NSError **) error_;

#pragma mark -
#pragma mark Joystick Elements

- (unsigned) numberOfButtons;

- (NSArray *) buttonElements;

#pragma mark -
#pragma mark Sticks - indexed accessors

- (unsigned int) countOfSticks;
- (DDHidJoystickStick *) objectInSticksAtIndex: (unsigned int)index;

- (void) addElementsToQueue: (DDHidQueue *) queue;

#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;

- (void) startListening;

- (void) stopListening;

@end

@interface NSObject (DDHidJoystickDelegate)

- (void) hidJoystick: (DDHidJoystick *)  joystick
               stick: (unsigned) stick
            xChanged: (int) value;
- (void) hidJoystick: (DDHidJoystick *)  joystick
               stick: (unsigned) stick
            yChanged: (int) value;
- (void) hidJoystick: (DDHidJoystick *) joystick
          buttonDown: (unsigned) buttonNumber;
- (void) hidJoystick: (DDHidJoystick *) joystick
            buttonUp: (unsigned) buttonNumber;

@end
