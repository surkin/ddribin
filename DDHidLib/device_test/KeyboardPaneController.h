//
//  KeyboardPaneController.h
//  DDHidLib
//
//  Created by Dave Dribin on 3/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DDHidKeyboard;

@interface KeyboardPaneController : NSObject
{
    IBOutlet NSArrayController * mKeyboardsController;
    IBOutlet NSArrayController * mKeyboardEventsController;

    NSArray * mKeyboards;
    unsigned mKeyboardIndex;
    NSMutableArray * mEvents;
    
    // Don't retain these
    DDHidKeyboard * mCurrentKeyboard;
}

- (NSArray *) keyboards;
- (void) setKeyboards: (NSArray *) theKeyboards;

- (unsigned) keyboardIndex;
- (void) setKeyboardIndex: (unsigned) theKeyboardIndex;

- (NSMutableArray *) events;
- (void) setEvents: (NSMutableArray *) theEvents;
- (void) addEvent: (id)theEvent;
- (void) removeEvent: (id)theEvent;

@end

@interface KeyboardPaneController (DDHidKeyboardDelegate)

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
               keyDown: (unsigned) usageId;

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
                 keyUp: (unsigned) usageId;

@end
