//
//  MyObject.h
//  DDDelegateHelper
//
//  Created by Dave Dribin on 1/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RUN_BENCHMARK 1
#define BENCHMARK_AUTORELEASE_COUNT 0

#if RUN_BENCHMARK
#define NSLog(...)
#endif

#define DELEGATE_OPTION 2

@class MyObjectDelegate;
@class MDelegateManager;

@interface MyObject : NSObject
{
#if (DELEGATE_OPTION == 1) || (DELEGATE_OPTION == 2) || (DELEGATE_OPTION == 4)
    id mDelegate;
#elif DELEGATE_OPTION == 3
    MyObjectDelegate * mDelegateHelper;
#endif
#if DELEGATE_OPTION == 4
    BOOL mHasDidDoSomethingDelegate;
    BOOL mHasShouldResetCountDelegate;
#endif
#if DELEGATE_OPTION == 5
    MDelegateManager * mDelegateManager;
#endif
    int mCount;
}

- (void) setDelegate: (id) delegate;
- (void) doSomething;
- (void) incrementCount;

@end

@interface NSObject (MyObjectDelegate)

- (void) myObjectDidDoSomething: (MyObject *) myObject;
- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;

@end