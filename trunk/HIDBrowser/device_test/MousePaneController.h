//
//  MousePaneController.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDHidQueue;
@class DDMouse;

@interface MousePaneController : NSObject
{
    IBOutlet NSArrayController * mMiceController;
    NSArray * mMice;
    DDMouse * mCurrentMouse;
    
    unsigned mMouseIndex;
    int mMouseX;
    int mMouseY;
    int mMouseWheel;
    NSMutableArray * mMouseButtons;
}

- (BOOL) no;

- (NSArray *) mice;
- (void) setMice: (NSArray *) newMice;

- (NSArray *) mouseButtons;

- (unsigned) mouseIndex;
- (void) setMouseIndex: (unsigned) theMouseIndex;

- (int) maxValue;

- (int) mouseX;

- (int) mouseY;

- (int) mouseWheel;

- (void) hidMouse: (DDMouse *) mouse xChanged: (SInt32) deltaX;
- (void) hidMouse: (DDMouse *) mouse yChanged: (SInt32) deltaY;
- (void) hidMouse: (DDMouse *) mouse wheelChanged: (SInt32) deltaWheel;

- (void) hidMouse: (DDMouse *) mouse buttonDown: (unsigned) buttonNumber;
- (void) hidMouse: (DDMouse *) mouse buttonUp: (unsigned) buttonNumber;

@end
