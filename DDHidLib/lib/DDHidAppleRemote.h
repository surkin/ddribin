//
//  DDHidAppleRemote.h
//  DDHidLib
//
//  Created by Dave Dribin on 2/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DDHidDevice.h"

@class DDHidElement;

enum DDHidAppleRemoteEventIdentifier
{
	kDDHidRemoteButtonVolume_Plus=0,
	kDDHidRemoteButtonVolume_Minus,
	kDDHidRemoteButtonMenu,
	kDDHidRemoteButtonPlay,
	kDDHidRemoteButtonRight,	
	kDDHidRemoteButtonLeft,	
	kDDHidRemoteButtonRight_Hold,	
	kDDHidRemoteButtonLeft_Hold,
	kDDHidRemoteButtonMenu_Hold,
	kDDHidRemoteButtonPlay_Sleep,
	kDDHidRemoteControl_Switched,
    kDDHidRemoteControl_Paired,
};
typedef enum DDHidAppleRemoteEventIdentifier DDHidAppleRemoteEventIdentifier;

@interface DDHidAppleRemote : DDHidDevice
{
    NSMutableDictionary * mCookieToButtonMapping;
    NSArray * mButtonElements;
    DDHidElement * mIdElement;
    int mRemoteId;

    id mDelegate;
}

+ (NSArray *) allRemotes;

+ (DDHidAppleRemote *) firstRemote;

- (id) initWithDevice: (io_object_t) device error: (NSError **) error_;

#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;

- (void) addElementsToDefaultQueue;

#pragma mark -
#pragma mark Properties

- (int) remoteId;
- (void) setRemoteId: (int) theRemoteId;

@end

@interface NSObject (DDHidAppleRemoteDelegate)

- (void) ddhidAppleRemoteButton: (DDHidAppleRemoteEventIdentifier) buttonIdentifier
                    pressedDown: (BOOL) pressedDown;

@end