//
//  AppleRemotePaneController.m
//  DDHidLib
//
//  Created by Dave Dribin on 2/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AppleRemotePaneController.h"
#import "RemoteFeedbackView.h"
#import "DDHidAppleRemote.h"

@implementation AppleRemotePaneController

- (void) awakeFromNib;
{
    [self willChangeValueForKey: @"remote"];
    mRemote = [[DDHidAppleRemote firstRemote] retain];
    [self didChangeValueForKey: @"remote"];
    
    [mRemote setDelegate: self];
    [self setOpenInExclusiveMode: YES];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mRemote release];
    
    mRemote = nil;
    [super dealloc];
}

- (DDHidAppleRemote *) remote;
{
    return mRemote;
}

- (IBAction) toggleListening: (id) sender;
{
    NSAssert(mRemote != nil, @"Remote is nil");
    
    if ([mRemote isListening])
    {
        [mRemote stopListening];
        [mStartStopButton setTitle: @"Start Listening"];
    }
    else
    {
        [mRemote setListenInExclusiveMode: mOpenInExclusiveMode];
        [mRemote startListening];
        [mStartStopButton setTitle: @"Stop Listening"];
    }
}

//=========================================================== 
//  openInExclusiveMode 
//=========================================================== 
- (BOOL) openInExclusiveMode
{
    return mOpenInExclusiveMode;
}

- (void) setOpenInExclusiveMode: (BOOL) flag
{
    mOpenInExclusiveMode = flag;
}

- (void) ddhidAppleRemoteButton: (DDHidAppleRemoteEventIdentifier) buttonIdentifier
                    pressedDown: (BOOL) pressedDown;
{
	NSString * buttonName= nil;
	NSString * pressed = @"";
	
	switch(buttonIdentifier)
    {
		case kDDHidRemoteButtonVolume_Plus:
			buttonName = @"Volume up";
			if (pressedDown) pressed = @"(down)"; else pressed = @"(up)";
			break;
		case kDDHidRemoteButtonVolume_Minus:
			buttonName = @"Volume down";
			if (pressedDown) pressed = @"(down)"; else pressed = @"(up)";
			break;			
		case kDDHidRemoteButtonMenu:
			buttonName = @"Menu";
			break;			
		case kDDHidRemoteButtonPlay:
			buttonName = @"Play";
			break;			
		case kDDHidRemoteButtonRight:	
			buttonName = @"Right";
			break;			
		case kDDHidRemoteButtonLeft:
			buttonName = @"Left";
			break;			
		case kDDHidRemoteButtonRight_Hold:
			buttonName = @"Right holding";	
			if (pressedDown) pressed = @"(down)"; else pressed = @"(up)";
			break;	
		case kDDHidRemoteButtonLeft_Hold:
			buttonName = @"Left holding";		
			if (pressedDown) pressed = @"(down)"; else pressed = @"(up)";
			break;			
		case kDDHidRemoteButtonPlay_Sleep:
			buttonName = @"Play (sleep mode)";
			break;			
		case kDDHidRemoteButtonMenu_Hold:
			buttonName = @"Menu (long)";
			break;
		case kDDHidRemoteControl_Switched:
			buttonName = @"Remote Control Switched";
			break;
        case kDDHidRemoteControl_Paired:
            buttonName = @"Remote Control Paired";
            break;
		default:
			NSLog(@"Unmapped event for button %d", buttonIdentifier); 
			break;
	}	
	[mFeedbackText setStringValue:[NSString stringWithFormat:@"%@ %@",
        buttonName, pressed]];

    [mFeedbackView ddhidAppleRemoteButton: buttonIdentifier
                              pressedDown: pressedDown];
}

@end
