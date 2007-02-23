//
//  AppleRemotePaneController.h
//  DDHidLib
//
//  Created by Dave Dribin on 2/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DDHidAppleRemote.h"

@class RemoteFeedbackView;

@interface AppleRemotePaneController : NSObject
{
    IBOutlet NSButton * mStartStopButton;
    IBOutlet RemoteFeedbackView * mFeedbackView;
	IBOutlet NSTextField * mFeedbackText;
    
    DDHidAppleRemote * mRemote;
    BOOL mOpenInExclusiveMode;
}

- (DDHidAppleRemote *) remote;

- (IBAction) toggleListening: (id) sender;

- (BOOL) openInExclusiveMode;
- (void) setOpenInExclusiveMode: (BOOL) flag;

- (void) ddhidAppleRemoteButton: (DDHidAppleRemoteEventIdentifier) buttonIdentifier
                    pressedDown: (BOOL) pressedDown;

@end
