/* RemoteFeedbackView */

#import <Cocoa/Cocoa.h>
#import "DDHidAppleRemote.h"

@interface RemoteFeedbackView : NSView
{
	NSImage* remoteImage;
	DDHidAppleRemoteEventIdentifier lastButtonIdentifier;
	BOOL drawn;
	BOOL clearAfterDraw;
}

- (void) ddhidAppleRemoteButton: (DDHidAppleRemoteEventIdentifier)buttonIdentifier 
                    pressedDown: (BOOL) pressedDown;

@end
