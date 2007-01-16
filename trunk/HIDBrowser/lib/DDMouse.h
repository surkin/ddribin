//
//  DDMouse.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDHidMouse;
@class DDHidQueue;

@interface DDMouse : NSObject
{
    DDHidMouse * mHidMouse;
    DDHidQueue * mQueue;
    
    id mDelegate;
    int mX;
    int mY;
    int mWheel;
    BOOL * mButtons;
}

- (id) initWithHidMouse: (DDHidMouse *) hidMouse;

+ (NSArray *) allMice;

- (DDHidMouse *) hidMouse;

- (void) setDelegate: (id) delegate;

- (void) startListening;

- (void) stopListening;

- (NSString *) productName;

- (NSString *) manufacturer;

@end

@interface NSObject (DDMouseDelegate)

- (void) hidMouse: (DDMouse *) mouse xChanged: (SInt32) deltaX;
- (void) hidMouse: (DDMouse *) mouse yChanged: (SInt32) deltaY;
- (void) hidMouse: (DDMouse *) mouse wheelChanged: (SInt32) deltaWheel;
- (void) hidMouse: (DDMouse *) mouse buttonDown: (unsigned) buttonNumber;
- (void) hidMouse: (DDMouse *) mouse buttonUp: (unsigned) buttonNumber;

@end
