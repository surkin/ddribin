//
//  BouncerView.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BouncerView.h"
#import "BouncerAppDelegate.h"
#import "BouncerVictim.h"
#import "DDHidLib.h"
#include <IOKit/hid/IOHIDUsageTables.h>

@interface BouncerSprite : NSObject
{
    NSImage * mImage;
    int mIndex;
    NSPoint mCurrentPoint;
    NSPoint mVelocity;
}

- (void) updateForElapsedTime: (NSTimeInterval) elapsedTime;

- (void) drawWithWidth: (float) width;

@end

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
              operation: NSCompositeSourceOver
               fraction: 1.0 - (mCurrentPoint.y / 200)];
}

@end


@implementation BouncerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        mSprites = [[NSMutableArray alloc] init];
        [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
                                         target: self
                                       selector: @selector(update:)
                                       userInfo: nil
                                        repeats: YES];
    }
    return self;
}

- (void) awakeFromNib;
{
    mKeyboards = [DDHidKeyboard allKeyboards];
    [mKeyboards retain];
    for (int i = 0; i < [mKeyboards count]; i++)
    {
        DDHidKeyboard * keyboard = [mKeyboards objectAtIndex: i];
        [keyboard setDelegate: self];
        [keyboard startListening];
    }
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (void) keyDown: (NSEvent *) event;
{
#if 0
    NSString * characters = [[event charactersIgnoringModifiers] lowercaseString];
    unichar firstChar = [characters characterAtIndex: 0];
    NSArray * victims = [mController victims];
    static const unichar keys[] = {
        'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 'z', 'x'
    };
    
    unsigned index = NSNotFound;
    int keyCount = sizeof(keys)/sizeof(keys[0]);
    for (int i = 0; i < keyCount; i++)
    {
        if (firstChar == keys[i])
        {
            index = i;
            break;
        }
    }
    
    if ((index != NSNotFound) && (index < [victims count]))
        [[victims objectAtIndex: index] bounce];
#endif
}

- (unsigned) indexForUsageId: (unsigned) usageId;
{
    static const int usages[] = {
        kHIDUsage_KeyboardA,
        kHIDUsage_KeyboardS,
        kHIDUsage_KeyboardD,
        kHIDUsage_KeyboardF,
        kHIDUsage_KeyboardG,
        kHIDUsage_KeyboardH,
        kHIDUsage_KeyboardJ,
        kHIDUsage_KeyboardK,
        kHIDUsage_KeyboardL,
        kHIDUsage_KeyboardY,
        kHIDUsage_KeyboardU,
        kHIDUsage_KeyboardI,
        kHIDUsage_KeyboardO,
        kHIDUsage_KeyboardP,
    };
    
    unsigned index = NSNotFound;
    int keyCount = sizeof(usages)/sizeof(usages[0]);
    for (int i = 0; i < keyCount; i++)
    {
        if (usageId == usages[i])
        {
            index = i;
            break;
        }
    }
    
    return index;
}

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
               keyDown: (unsigned) usageId;
{
    unsigned index = [self indexForUsageId: usageId];
    NSArray * victims = [mController victims];
    if ((index != NSNotFound) && (index < [victims count]))
    {
        BouncerVictim * victim = [victims objectAtIndex: index];
        [victim bounce];
        [victim setEffect: YES];
        // [mController updateQCIcons];
        NSImage * image = [victim icon];
        BouncerSprite * sprite = [[BouncerSprite alloc] initWithImage: image
                                                              atPoint: NSZeroPoint];
        [sprite setVelocity: NSMakePoint(0, 150)];
        [sprite setIndex: index];
        [sprite autorelease];
        [mSprites addObject: sprite];
        [self setNeedsDisplay: YES];
    }
}


- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
               keyUp: (unsigned) usageId;
{
    unsigned index = [self indexForUsageId: usageId];
    NSArray * victims = [mController victims];
    if ((index != NSNotFound) && (index < [victims count]))
    {
        BouncerVictim * victim = [victims objectAtIndex: index];
        [victim setEffect: NO];
        // [mController updateQCIcons];
    }
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
            NSLog(@"Removing: %d", i);
            [spritesToRemove addIndex: i];
        }
    }
    [mSprites removeObjectsAtIndexes: spritesToRemove];
    [self setNeedsDisplay: YES];
}

- (void) drawRect: (NSRect) rect
{
    // NSGraphicsContext * nsContext = [NSGraphicsContext currentContext];
    [[NSColor whiteColor] set];
    NSRectFill(rect);
    
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
