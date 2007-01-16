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
}

+ (NSArray *) allMice;

- (id) initWithDevice: (io_object_t) device;

- (DDHidElement *) xElement;

- (DDHidElement *) yElement;

- (DDHidElement *) wheelElement;

- (NSArray *) buttonElements;

- (unsigned) numberOfButtons;

- (void) addElementsToQueue: (DDHidQueue *) queue;

@end
