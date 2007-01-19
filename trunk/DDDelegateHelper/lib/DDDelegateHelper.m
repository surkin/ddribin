//
//  DDDelegateHelper.m
//  delegate
//
//  Created by Dave Dribin on 1/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDDelegateHelper.h"


@implementation DDDelegateHelper

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mSelectors = [[NSMutableDictionary alloc] init];
    
    return self;
}

//=========================================================== 
// - delegate
//=========================================================== 
- (id) delegate
{
    return mDelegate; 
}

//=========================================================== 
// - setDelegate:
//=========================================================== 
- (void) setDelegate: (id) theDelegate
{
    mDelegate = theDelegate;
    [mSelectors removeAllObjects];
}

- (BOOL) shouldCallSelector: (SEL) selector;
{
    NSValue * selectorValue = [NSValue valueWithPointer: selector];
    NSNumber * shouldCallSelector = [mSelectors objectForKey: selectorValue];
    if (shouldCallSelector == nil)
    {
        if ([mDelegate respondsToSelector: selector])
            shouldCallSelector = [NSNumber numberWithBool: YES];
        else
            shouldCallSelector = [NSNumber numberWithBool: NO];
        [mSelectors setObject: shouldCallSelector
                       forKey: selectorValue];
    }
    return [shouldCallSelector boolValue];
}

- (BOOL) willCallSelector: (SEL) selector;
{
    BOOL shouldCallSelector = [self shouldCallSelector: selector];
    BOOL calledDelegate = NO;
    if (shouldCallSelector)
        calledDelegate = YES;
    mCalledDelegate = calledDelegate;
    return shouldCallSelector;
}

- (BOOL) calledDelegate;
{
    return mCalledDelegate;
}

@end
