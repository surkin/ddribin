//
//  ButtonState.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ButtonState.h"

@implementation ButtonState

- (id) initWithName: (NSString *) name
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mName = [name retain];
    mPressed = NO;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mName release];
    
    mName = nil;
    [super dealloc];
}

//=========================================================== 
// - name
//=========================================================== 
- (NSString *) name
{
    return mName; 
}

//=========================================================== 
// - pressed
//=========================================================== 
- (BOOL) pressed
{
    return mPressed;
}

//=========================================================== 
// - setPressed:
//=========================================================== 
- (void) setPressed: (BOOL) flag
{
    mPressed = flag;
}

@end

