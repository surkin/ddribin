//
//  DDHidEvent.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidEvent.h"


@implementation DDHidEvent

+ (DDHidEvent *) eventWithIOHIDEvent: (IOHIDEventStruct *) event;
{
    return [[[self alloc] initWithIOHIDEvent: event] autorelease];
}

- (id) initWithIOHIDEvent: (IOHIDEventStruct *) event;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mEvent = *event;
    
    return self;
}

- (IOHIDElementType) type;
{
    return mEvent.type;
}

- (IOHIDElementCookie) elementCookie;
{
    return mEvent.elementCookie;
}

- (unsigned) elementCookieAsUnsigned;
{
    return (unsigned) mEvent.elementCookie;
}

- (SInt32) value;
{
    return mEvent.value;
}

- (AbsoluteTime) timestamp;
{
    return mEvent.timestamp;
}

- (UInt32) longValueSize;
{
    return mEvent.longValueSize;
}

- (void *) longValue;
{
    return mEvent.longValue;
}

@end
