//
//  DeviceTestController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MousePaneController.h"
#import "DDHidMouse.h"
#import "DDHidQueue.h"
#import "DDHidEvent.h"
#import "DDHidElement.h"
#import "DDHidUsage.h"
#import "DDMouse.h"


@interface ButtonState : NSObject
{
    NSString * mName;
    BOOL mPressed;
}

- (NSString *) name;

- (BOOL) pressed;
- (void) setPressed: (BOOL) flag;

@end

@implementation ButtonState

- (id) initWithName: (NSString *) name
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mName = [name retain];
    mPressed = NO;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mName release];

    mName = nil;
    [super dealloc];
}

//=========================================================== 
// - name
//=========================================================== 
- (NSString *) name
{
    return mName; 
}

//=========================================================== 
// - pressed
//=========================================================== 
- (BOOL) pressed
{
    return mPressed;
}

//=========================================================== 
// - setPressed:
//=========================================================== 
- (void) setPressed: (BOOL) flag
{
    mPressed = flag;
}

@end


@interface MousePaneController (Private)

- (void) setMouseX: (int) mouseX;
- (void) setMouseY: (int) mouseY;
- (void) setMouseWheel: (int) mouseWheel;

@end

@implementation MousePaneController

static DDHidMouse * mDevice;

static int sMaxValue = 2500;

static int applyDelta(int current, int delta)
{
    int newValue = (current + delta) % sMaxValue;
    if (newValue < 0)
        newValue = sMaxValue + newValue;
    return newValue;
}

- (void) awakeFromNib;
{
    NSLog(@"DeviceTestController");
    mCurrentMouse = 0;
    mMouseButtons = [[NSMutableArray alloc] init];

    NSArray * mice = [DDMouse allMice];
    NSEnumerator * e = [mice objectEnumerator];
    DDMouse * mouse;
    while (mouse = [e nextObject])
    {
        [mouse setDelegate: self];
        NSLog(@"Product name: %@",
              [mouse productName]);
    }
    [self setMice: mice];
    [self setMouseIndex: 0];
    // [self setMice: [NSArray array]];
    // [self setMouseIndex: NSNotFound];
}

//=========================================================== 
//  mice 
//=========================================================== 
- (NSArray *) mice
{
    return mMice; 
}

- (void) setMice: (NSArray *) theMice
{
    if (mMice != theMice)
    {
        [mMice release];
        mMice = [theMice retain];
    }
}

- (NSArray *) mouseButtons;
{
    return mMouseButtons;
}

- (BOOL) no;
{
    return NO;
}

//=========================================================== 
// - mouseIndex
//=========================================================== 
- (unsigned) mouseIndex
{
    return mMouseIndex;
}

//=========================================================== 
// - setMouseIndex:
//=========================================================== 
- (void) setMouseIndex: (unsigned) theMouseIndex
{
    if (mCurrentMouse != nil)
    {
        [mCurrentMouse stopListening];
        mCurrentMouse = nil;
    }
    mMouseIndex = theMouseIndex;
    [mMiceController setSelectionIndex: mMouseIndex];
    if (mMouseIndex != NSNotFound)
    {
        mCurrentMouse = [mMice objectAtIndex: mMouseIndex];
        [mCurrentMouse startListening];
        [self setMouseX: sMaxValue/2];
        [self setMouseY: sMaxValue/2];
        [self setMouseWheel: sMaxValue/2];

        [self willChangeValueForKey: @"mouseButtons"];
        [mMouseButtons removeAllObjects];
        NSArray * buttons = [[mCurrentMouse hidMouse] buttonElements];
        NSEnumerator * e = [buttons objectEnumerator];
        DDHidElement * element;
        while (element = [e nextObject])
        {
            ButtonState * state = [[ButtonState alloc] initWithName: [[element usage] usageName]];
            [state autorelease];
            [mMouseButtons addObject: state];
        }
        [self didChangeValueForKey: @"mouseButtons"];
    }
}

- (int) maxValue;
{
    return sMaxValue;
}

//=========================================================== 
// - mouseX
//=========================================================== 
- (int) mouseX
{
    return mMouseX;
}

//=========================================================== 
// - mouseY
//=========================================================== 
- (int) mouseY
{
    return mMouseY;
}

//=========================================================== 
// - mouseWheel
//=========================================================== 
- (int) mouseWheel
{
    return mMouseWheel;
}


- (void) hidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while (event = [hidQueue nextEvent])
    {
        DDHidElement * element = [mDevice elementForCookie: [event elementCookie]];
        NSLog(@"Element: %@, value: %d", [[element usage] usageName], [event value]);
    }
}

- (void) hidMouse: (DDMouse *) mouse xChanged: (SInt32) deltaX;
{
    [self setMouseX: applyDelta(mMouseX, deltaX)];
}

- (void) hidMouse: (DDMouse *) mouse yChanged: (SInt32) deltaY;
{
    [self setMouseY: applyDelta(mMouseY, deltaY)];
}

- (void) hidMouse: (DDMouse *) mouse wheelChanged: (SInt32) deltaWheel;
{
    // Some wheels only output -1 or +1, some output a more analog value.
    // Normalize wheel to -1%/+1% movement.
    deltaWheel = (deltaWheel/abs(deltaWheel))*(sMaxValue/100);
    [self setMouseWheel: applyDelta(mMouseWheel, deltaWheel)];
}

- (void) hidMouse: (DDMouse *) mouse buttonDown: (unsigned) buttonNumber;
{
    ButtonState * state = [mMouseButtons objectAtIndex: buttonNumber];
    [state setPressed: YES];
}

- (void) hidMouse: (DDMouse *) mouse buttonUp: (unsigned) buttonNumber;
{
    ButtonState * state = [mMouseButtons objectAtIndex: buttonNumber];
    [state setPressed: NO];
}

@end

@implementation MousePaneController (Private)

- (void) setMouseX: (int) mouseX;
{
    mMouseX = mouseX;
}

- (void) setMouseY: (int) mouseY;
{
    mMouseY = mouseY;
}

- (void) setMouseWheel: (int) mouseWheel;
{
    mMouseWheel = mouseWheel;
}

@end

