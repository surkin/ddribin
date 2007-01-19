//
//  MyObject.m
//  DDDelegateHelper
//
//  Created by Dave Dribin on 1/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MyObject.h"

#if DELEGATE_OPTION == 2

@interface MyObject (MyObjectDelegate)

- (void) myObjectDidDoSomething: (MyObject *) myObject;
- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;

@end

#endif

#if DELEGATE_OPTION == 3

#import "DDDelegateHelper.h"

@interface MyObjectDelegate : DDDelegateHelper

- (void) myObjectDidDoSomething: (MyObject *) myObject;
- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;

@end

#endif


@implementation MyObject

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
#if DELEGATE_OPTION == 3
    mDelegateHelper = [[MyObjectDelegate alloc] init];
#endif
#if DELEGATE_OPTION==  4
    mHasDidDoSomethingDelegate = NO;
    mHasShouldResetCountDelegate = NO;
#endif
    mCount = 0;
    
    return self;
}

- (void) dealloc;
{
#if DELEGATE_OPTION == 3
    [mDelegateHelper release];
    
    mDelegateHelper = nil;
#endif
    [super dealloc];
}

- (void) setDelegate: (id) delegate;
{
#if (DELEGATE_OPTION == 1) || (DELEGATE_OPTION == 2)
    mDelegate = delegate;
#elif DELEGATE_OPTION == 3
    [mDelegateHelper setDelegate: delegate];
#elif DELEGATE_OPTION == 4
    mDelegate = delegate;
    mHasDidDoSomethingDelegate = NO;
    mHasShouldResetCountDelegate = NO;
    if ([mDelegate respondsToSelector: @selector(myObjectDidDoSomething:)])
        mHasDidDoSomethingDelegate = YES;
    if ([mDelegate respondsToSelector: @selector(myObjectShouldResetCount:count:)])
        mHasShouldResetCountDelegate = YES;
#endif
}

- (void) doSomething;
{
    NSLog(@"did something");
#if DELEGATE_OPTION == 1
    if ([mDelegate respondsToSelector: @selector(myObjectDidDoSomething:)])
        [mDelegate myObjectDidDoSomething: self];
#elif DELEGATE_OPTION == 2
    [self myObjectDidDoSomething: self];
#elif DELEGATE_OPTION == 3
    [mDelegateHelper myObjectDidDoSomething: self];
#elif DELEGATE_OPTION == 4
    if (mHasDidDoSomethingDelegate);
        [mDelegate myObjectDidDoSomething: self];
#endif
}

- (void) incrementCount;
{
    mCount++;
    NSLog(@"Incremented count to: %d", mCount);
#if DELEGATE_OPTION == 1
    if ([mDelegate respondsToSelector: @selector(myObjectShouldResetCount:count:)])
    {
        if ([mDelegate myObjectShouldResetCount: self count: mCount])
        {
            mCount = 0;
        }
    }
#elif DELEGATE_OPTION == 2
    if ([self myObjectShouldResetCount: self count: mCount])
        mCount = 0;
#elif DELEGATE_OPTION == 3
    if ([mDelegateHelper myObjectShouldResetCount: self count: mCount] == YES)
        mCount = 0;
#elif DELEGATE_OPTION == 4
    if (mHasShouldResetCountDelegate)
    {
        if ([mDelegate myObjectShouldResetCount: self count: mCount])
        {
            mCount = 0;
        }
    }
#endif
}

@end

#if DELEGATE_OPTION == 2

@implementation MyObject (MyObjectDelegate)

- (void) myObjectDidDoSomething: (MyObject *) myObject;
{
    if ([mDelegate respondsToSelector: _cmd])
        [mDelegate myObjectDidDoSomething: self];
}

- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;
{
    if ([mDelegate respondsToSelector: _cmd])
        return [mDelegate myObjectShouldResetCount: self count: mCount];
    else
        return NO;
}

@end

#endif


#if DELEGATE_OPTION == 3

@implementation MyObjectDelegate

- (void) myObjectDidDoSomething: (MyObject *) myObject;
{
    if ([self shouldCallSelector: _cmd])
        [mDelegate myObjectDidDoSomething: myObject];
}

- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;
{
    if ([self shouldCallSelector: _cmd])
        return [mDelegate myObjectShouldResetCount: myObject count: count];
    else
        return NO;
}

@end

#endif
