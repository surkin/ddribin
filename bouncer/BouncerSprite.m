//
//  BouncerSprite.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BouncerSprite.h"


@implementation BouncerSprite

- (id) initWithImage: (NSImage *) image atPoint: (NSPoint) point;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mImage = [image retain];
    mCurrentPoint = point;
    mVelocity = NSZeroPoint;
    
    return self;
}

- (NSPoint) currentPoint;
{
    return mCurrentPoint;
}

- (void) setVelocity: (NSPoint) velocity;
{
    mVelocity = velocity;
}

- (void) updateForElapsedTime: (NSTimeInterval) elapsedTime;
{
    mCurrentPoint.x += mVelocity.x * elapsedTime;
    mCurrentPoint.y += mVelocity.y * elapsedTime;
}

- (void) update: (float) width x: (float) x;
{
}

- (void) setIndex: (int) index;
{
    mIndex = index;
}

- (void) drawWithWidth: (float) width;
{
    [mImage setSize: NSMakeSize(width, width)];
    mCurrentPoint.x = mIndex * width;;
    [mImage drawAtPoint: mCurrentPoint
               fromRect: NSZeroRect
              operation: NSCompositeSourceAtop
               fraction: 1.0 - (mCurrentPoint.y / 200)];
}

@end

