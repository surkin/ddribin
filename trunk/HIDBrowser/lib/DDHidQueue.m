//
//  DDHidQueue.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidQueue.h"
#import "DDHidElement.h"
#import "DDHIdEvent.h"

static void queueCallbackFunction(void* target,  IOReturn result, void* refcon,
                                  void* sender);

@interface DDHidQueue (Private)

- (void) handleQueueCallback;

@end

@implementation DDHidQueue

- (id) initWithHIDQueue: (IOHIDQueueInterface **) queue
                   size: (unsigned) size;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mQueue = queue;
    IOReturn result = (*mQueue)->create(mQueue, 0, size);
    if (result != kIOReturnSuccess)
    {
        [self release];
        return nil;
    }
     
    return self;
}

- (void) dealloc;
{
    [self stop];
    (*mQueue)->dispose(mQueue);
    (*mQueue)->Release(mQueue);
    [super dealloc];
}

- (void) addElement: (DDHidElement *) element;
{
    IOHIDElementCookie cookie = [element cookie];
    (*mQueue)->addElement(mQueue, cookie, 0);
}

- (void) setDelegate: (id) delegate;
{
    mDelegate = delegate;
}

- (void) startOnCurrentRunLoop;
{
    [self startOnRunLoop: [NSRunLoop currentRunLoop]];
}

- (void) startOnRunLoop: (NSRunLoop *) runLoop;
{
    if (mStarted)
        return;
    
    mRunLoop = [runLoop retain];
    
    IOReturn result;
    result = (*mQueue)->createAsyncEventSource(mQueue, &mEventSource);
    if (result == kIOReturnSuccess)
    {
        result = (*mQueue)->setEventCallout(mQueue, queueCallbackFunction, self, NULL);
        if (result == kIOReturnSuccess)
        {
            CFRunLoopAddSource([mRunLoop getCFRunLoop], mEventSource,
                               kCFRunLoopDefaultMode);
            (*mQueue)->start(mQueue);
            mStarted = YES;
        }
        else
            NSLog(@"Error setting event callout");
    }
    else
        NSLog(@"Error creating async event source");
    
}

- (void) stop;
{
    if (!mStarted)
        return;
    
    CFRunLoopRemoveSource([mRunLoop getCFRunLoop], mEventSource, kCFRunLoopDefaultMode);
    (*mQueue)->stop(mQueue);
    [mRunLoop release];
    mRunLoop = nil;
    mStarted = NO;
}

- (BOOL) isStarted;
{
    return mStarted;
}

- (BOOL) getNextEvent: (IOHIDEventStruct *) event;
{
    AbsoluteTime zeroTime = {0, 0};
    IOReturn result = (*mQueue)->getNextEvent(mQueue, event, zeroTime, 0);
    return (result == kIOReturnSuccess);
}

- (DDHidEvent *) nextEvent;
{
    AbsoluteTime zeroTime = {0, 0};
    IOHIDEventStruct event;
    IOReturn result = (*mQueue)->getNextEvent(mQueue, &event, zeroTime, 0);
    if (result != kIOReturnSuccess)
        return nil;
    else
        return [DDHidEvent eventWithIOHIDEvent: &event];
}

@end

@implementation DDHidQueue (Private)

- (void) handleQueueCallback;
{
    if ([mDelegate respondsToSelector: @selector(hidQueueHasEvents:)])
    {
        [mDelegate hidQueueHasEvents: self];
    }
}

@end

static void queueCallbackFunction(void* target,  IOReturn result, void* refcon,
                                  void* sender)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDHidQueue * queue = (DDHidQueue *) target;
    [queue handleQueueCallback];
    [pool release];
    
}
