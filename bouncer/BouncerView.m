//
//  BouncerView.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BouncerView.h"
#import "BouncerController.h"
#import "BouncerVictim.h"
#import "BouncerSprite.h"
#import "DDHidLib.h"
#import "CTGradient.h"
#include <IOKit/hid/IOHIDUsageTables.h>



@implementation BouncerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    mSprites = [[NSMutableArray alloc] init];
    [self startAnimation];
#if 0
    // mGradient = [[CTGradient unifiedNormalGradient] retain];
#elif 0
    
    NSColor * start = [NSColor colorWithDeviceRed: 1.0 green: 1.0 blue: 1.0
                                            alpha: 1.0];
    NSColor * end = [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 1.0
                                            alpha: 0.0];
    mGradient = [[CTGradient gradientWithBeginningColor: start
                                            endingColor: end] retain];
#else
    mGradient = [[CTGradient unifiedSelectedGradient] retain];
#endif

    return self;
}

- (void) awakeFromNib;
{
#if 0
    mKeyboards = [DDHidKeyboard allKeyboards];
    [mKeyboards retain];
    for (int i = 0; i < [mKeyboards count]; i++)
    {
        DDHidKeyboard * keyboard = [mKeyboards objectAtIndex: i];
        [keyboard setDelegate: self];
        [keyboard startListening];
    }
#endif
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (void) keyDown: (NSEvent *) event;
{
    // Empty implementation stops the beeping
}

- (void) startAnimation;
{
    [self stopAnimation];
    mAnimationTimer = 
        [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
                                         target: self
                                       selector: @selector(update:)
                                       userInfo: nil
                                        repeats: YES];
    [mAnimationTimer retain];
}

- (void) stopAnimation;
{
    [mAnimationTimer invalidate];
    [mAnimationTimer release];
    mAnimationTimer = nil;
}

- (void) addSprite: (BouncerSprite *) sprite;
{
    [mSprites addObject: sprite];
}

- (void) update: (NSTimer *) timer;
{
    NSMutableIndexSet * spritesToRemove = [NSMutableIndexSet indexSet];
    NSRect bounds = [self bounds];
    float height = bounds.size.height;

    for (int i = 0; i < [mSprites count]; i++)
    {
        BouncerSprite * sprite = [mSprites objectAtIndex: i];
        [sprite updateForElapsedTime: [timer timeInterval]];
        if ([sprite currentPoint].y > height)
        {
            [spritesToRemove addIndex: i];
        }
    }
    [mSprites removeObjectsAtIndexes: spritesToRemove];
    [self setNeedsDisplay: YES];
}

- (void) drawRect: (NSRect) rect
{
    // NSGraphicsContext * nsContext = [NSGraphicsContext currentContext];
#if 0
    [[NSColor whiteColor] set];
    NSRectFill(rect);
#else
    [mGradient fillRect: rect angle: 90.0];
#endif
    
    NSRect bounds = [self bounds];
    float width = bounds.size.width;
    float eachWidth = width/[[mController victims] count];
    
    for (int i = 0; i < [mSprites count]; i++)
    {
        BouncerSprite * sprite = [mSprites objectAtIndex: i];
        [sprite drawWithWidth: eachWidth];
    }
}

@end
