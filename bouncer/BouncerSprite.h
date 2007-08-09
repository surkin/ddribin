//
//  BouncerSprite.h
//  TheBouncer
//
//  Created by Dave Dribin on 8/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BouncerSprite : NSObject
{
    NSImage * mImage;
    int mIndex;
    NSPoint mCurrentPoint;
    NSPoint mVelocity;
}

- (id) initWithImage: (NSImage *) image atPoint: (NSPoint) point;

- (NSPoint) currentPoint;

- (void) setVelocity: (NSPoint) velocity;

- (void) setIndex: (int) index;

- (void) updateForElapsedTime: (NSTimeInterval) elapsedTime;

- (void) drawWithWidth: (float) width;

@end
