#import <Foundation/Foundation.h>
#import "MyObject.h"

@interface MyTest : NSObject
{
}

+ (MyTest *) test;

- (void) run;

@end

@interface MyTest (MyObjectDelegate)

- (void) myObjectDidDoSomething: (MyObject *) myObject;
- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;

@end

@implementation MyTest

+ (MyTest *) test;
{
    return [[[self alloc] init] autorelease];
}

- (void) run;
{
    MyObject * object = [[MyObject alloc] init];
    
#if !RUN_BENCHMARK
    [object doSomething];
    [object incrementCount];
    [object incrementCount];
    
    [object setDelegate: self];
    [object doSomething];
    [object incrementCount];
    [object incrementCount];
#else
    [object setDelegate: self];
    NSDate * start = [NSDate date];
#if DELEGATE_OPTION == 3
    int invocations = 10000000;
#else
    int invocations = 100000000;
#endif
    int i;
    for (i = 0; i < invocations; i++)
    {
        [object doSomething];
    }
    NSDate * finish = [NSDate date];
    NSTimeInterval time = [finish timeIntervalSinceDate: start];
    float invocationsPerSecond = ((float)invocations)/time;
    printf("Total time: %lf for %d invocations, Mi/s: %lf\n",
           time, invocations, (invocationsPerSecond/1000000));
#endif
    
    [object setDelegate: nil];
    [object release];
}

@end

@implementation MyTest (MyObjectDelegate)

- (void) myObjectDidDoSomething: (MyObject *) myObject;
{
    NSLog(@"doSomething delegate");
}

- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;
{
    NSLog(@"shouldResetCount delegate, current count: %d", count);
    if (count >= 2)
        return YES;
    else
        return NO;
}

@end

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

#if DELEGATE_OPTION == 1
    printf("Delegate option 1: inline respondsToSelector\n");
#elif DELEGATE_OPTION == 2
    printf("Delegate option 2: separate respondsToSelector\n");
#elif DELEGATE_OPTION == 3
    printf("Delegate option 3: delegate helper\n");
#elif DELEGATE_OPTION == 4
    printf("Delegate option 4: ivar cache\n");
#else
#error Invalid DELEGATE_OPTION 
#endif

    MyTest * test = [MyTest test];
    [test run];
   
    [pool release];
    return 0;
}
