//
//  DDHidQueue.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/hid/IOHIDLib.h>

@class DDHidElement;
@class DDHidEvent;

@interface DDHidQueue : NSObject
{
    IOHIDQueueInterface ** mQueue;
    NSRunLoop * mRunLoop;
    BOOL mStarted;
    
    id mDelegate;
    CFRunLoopSourceRef mEventSource;
}

- (id) initWithHIDQueue: (IOHIDQueueInterface **) queue
                   size: (unsigned) size;

- (void) addElement: (DDHidElement *) element;

- (void) addElements: (NSArray *) elements;

- (void) setDelegate: (id) delegate;

- (void) startOnCurrentRunLoop;

- (void) startOnRunLoop: (NSRunLoop *) runLoop;

- (void) stop;

- (BOOL) isStarted;

- (BOOL) getNextEvent: (IOHIDEventStruct *) event;

- (DDHidEvent *) nextEvent;

@end

@interface NSObject (DDHidQueueDelegate)

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;

@end
