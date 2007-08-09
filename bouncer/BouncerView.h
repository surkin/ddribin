//
//  BouncerView.h
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BouncerAppDelegate;
@class BouncerSprite;
@class DDHidKeyboard;
@class CTGradient;

@interface BouncerView : NSView
{
    IBOutlet BouncerAppDelegate * mController;
    NSArray * mKeyboards;
    NSMutableArray * mSprites;
    CTGradient * mGradient;
    NSTimer * mAnimationTimer;
}

- (void) addSprite: (BouncerSprite *) sprite;

- (void) startAnimation;
- (void) stopAnimation;

@end
