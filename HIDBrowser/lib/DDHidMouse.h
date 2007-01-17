//
//  DDHidMouse.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHidDevice.h"

@class DDHidElement;
@class DDHidQueue;

@interface DDHidMouse : DDHidDevice
{
    DDHidElement * mXElement;
    DDHidElement * mYElement;
    DDHidElement * mWheelElement;
    NSMutableArray * mButtonElements;
    
    DDHidQueue * mQueue;
    id mDelegate;
}

+ (NSArray *) allMice;

- (id) initWithDevice: (io_object_t) device;

- (DDHidElement *) xElement;

- (DDHidElement *) yElement;

- (DDHidElement *) wheelElement;

- (NSArray *) buttonElements;

- (unsigned) numberOfButtons;

- (void) addElementsToQueue: (DDHidQueue *) queue;

- (void) setDelegate: (id) delegate;

- (void) startListening;

- (void) stopListening;

@end

@interface NSObject (DDHidMouseDelegate)

- (void) hidMouse: (DDHidMouse *) mouse xChanged: (SInt32) deltaX;
- (void) hidMouse: (DDHidMouse *) mouse yChanged: (SInt32) deltaY;
- (void) hidMouse: (DDHidMouse *) mouse wheelChanged: (SInt32) deltaWheel;
- (void) hidMouse: (DDHidMouse *) mouse buttonDown: (unsigned) buttonNumber;
- (void) hidMouse: (DDHidMouse *) mouse buttonUp: (unsigned) buttonNumber;

@end
