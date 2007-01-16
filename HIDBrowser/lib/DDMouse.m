//
//  DDMouse.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMouse.h"
#import "DDHidMouse.h"
#import "DDHidQueue.h"
#import "DDHidElement.h"
#import "DDHidUsage.h"
#import "DDHidEvent.h"

@implementation DDMouse

- (id) initWithHidMouse: (DDHidMouse *) hidMouse;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHidMouse = [hidMouse retain];
    mQueue = nil;
    [mHidMouse open];
    
    mButtons = malloc(sizeof(BOOL) * [mHidMouse numberOfButtons]);
    
    return self;
}

- (void) dealloc;
{
    [mQueue release];
    [mHidMouse release];
    if (mButtons != NULL)
        free(mButtons);
    
    [super dealloc];
}

+ (NSArray *) allMice;
{
    NSMutableArray * mice = [NSMutableArray array];
    NSArray * hidMice = [DDHidMouse allMice];
    NSEnumerator * e = [hidMice objectEnumerator];
    DDHidMouse * hidMouse;
    while (hidMouse = [e nextObject])
    {
        DDHidMouse * mouse = [[self alloc] initWithHidMouse: hidMouse];
        if (mouse != nil)
            [mice addObject: mouse];
    }
    return mice;
}

- (DDHidMouse *) hidMouse;
{
    return mHidMouse;
}

- (void) setDelegate: (id) delegate;
{
    mDelegate = delegate;
}

- (void) startListening;
{
    if (mQueue != nil)
        return;
    
    mQueue = [[mHidMouse createQueueWithSize: 10] retain];
    [mQueue setDelegate: self];
    [mHidMouse addElementsToQueue: mQueue];
    [mQueue startOnCurrentRunLoop];
}

- (void) stopListening;
{
    if (mQueue == nil)
        return;
    
    [mQueue stop];
    [mQueue release];
    mQueue = nil;
}

- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        IOHIDElementCookie cookie = [event elementCookie];
        SInt32 value = [event value];
        if (cookie == [[mHidMouse xElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:xChanged:)])
            {
                [mDelegate hidMouse: self xChanged: value];
            }
        }
        else if (cookie == [[mHidMouse yElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:yChanged:)])
            {
                [mDelegate hidMouse: self yChanged: value];
            }
        }
        else if (cookie == [[mHidMouse wheelElement] cookie])
        {
            if ((value != 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:wheelChanged:)])
            {
                [mDelegate hidMouse: self wheelChanged: value];
            }
        }
        else
        {
            unsigned i = 0;
            for (i = 0; i < [[mHidMouse buttonElements] count]; i++)
            {
                if (cookie == [[[mHidMouse buttonElements] objectAtIndex: i] cookie])
                    break;
            }
            
            if ((value == 1) &&
                [mDelegate respondsToSelector: @selector(hidMouse:buttonDown:)])
            {
                [mDelegate hidMouse: self buttonDown: i];
            }
            else if ((value == 0) &&
                [mDelegate respondsToSelector: @selector(hidMouse:buttonUp:)])
            {
                [mDelegate hidMouse: self buttonUp: i];
            }
            else
            {
                DDHidElement * element = [mHidMouse elementForCookie: [event elementCookie]];
                NSLog(@"Element: %@, value: %d", [[element usage] usageName], [event value]);
            }
        }
    }
}

#pragma mark -

- (NSString *) productName;
{
    return [mHidMouse productName];
}

- (NSString *) manufacturer;
{
    return [mHidMouse manufacturer];
}

@end
