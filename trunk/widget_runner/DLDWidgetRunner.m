//
//  DLDWidgetRunner.m
//  WidgetRun
//
//  Created by Dave Dribin on 7/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DLDWidgetRunner.h"
#include <objc/objc-class.h>

/**
* Renames the selector for a given method.
 * Searches for a method with _oldSelector and reassigned _newSelector to that
 * implementation.
 * @return NO on an error and the methods were not swizzled
 */
BOOL DTRenameSelector(Class _class, SEL _oldSelector, SEL _newSelector)
{
    Method method = nil;
    
    // First, look for the methods
    method = class_getInstanceMethod(_class, _oldSelector);
    if (method == nil)
        return NO;
    
    method->method_name = _newSelector;
    return YES;
}

@interface WidgetInstallerController : NSObject

- (void) run: (id) target;
- (void) orig_run: (id) target;

- (void) ok: (id) target;
- (void) orig_ok: (id) target;

@end

@interface WidgetInstallerController (DLD)

- (void) dld_run: (id) target;
- (void) dld_ok: (id) target;

@end

@implementation WidgetInstallerController (DLD)

- (void) dld_run: (id) target;
{
    NSLog(@"Swizzle run:");
    [self orig_run: target];
}

- (void) dld_ok: (id) target;
{
    NSLog(@"Swizzle ok:");
    [self run: target];
}

@end

@implementation DLDWidgetRunner

+ (void) load
{
    NSLog(@"In [DLDWidgetRunnger load]");
    Class aClass = [WidgetInstallerController class];
    BOOL rc;
    
    rc = DTRenameSelector(aClass, @selector(run:), @selector(orig_run:));
    NSLog(@"rc: %d", rc);

    rc = DTRenameSelector(aClass, @selector(dld_run:), @selector(run:));
    NSLog(@"rc: %d", rc);

    rc = DTRenameSelector(aClass, @selector(ok:), @selector(orig_ok:));
    NSLog(@"rc: %d", rc);
    
    rc = DTRenameSelector(aClass, @selector(dld_ok:), @selector(ok:));
    NSLog(@"rc: %d", rc);
    
    NSLog(@"(%d): %@", __LINE__, [[NSProcessInfo processInfo] arguments]);

    WidgetInstallerController * controller = [NSApp targetForAction: @selector(run:)];
    NSLog(@"(%d) target: %@", __LINE__, controller);
    [controller performSelectorOnMainThread: @selector(run:) withObject: nil waitUntilDone: NO];
}

@end
