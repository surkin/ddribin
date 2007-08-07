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

@implementation BouncerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
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

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
               keyDown: (unsigned) usageId;
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
    
    NSArray * victims = [mController victims];
    if ((index != NSNotFound) && (index < [victims count]))
        [[victims objectAtIndex: index] bounce];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

@end
