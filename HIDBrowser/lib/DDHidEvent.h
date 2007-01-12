//
//  DDHidEvent.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/hid/IOHIDLib.h>

@interface DDHidEvent : NSObject
{
    IOHIDEventStruct mEvent;
}

+ (DDHidEvent *) eventWithIOHIDEvent: (IOHIDEventStruct *) event;

- (id) initWithIOHIDEvent: (IOHIDEventStruct *) event;

- (IOHIDElementType) type;
- (IOHIDElementCookie) elementCookie;
- (SInt32) value;
- (AbsoluteTime) timestamp;
- (UInt32) longValueSize;
- (void *) longValue;

@end
