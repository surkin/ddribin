//
//  Bouncer.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Bouncer.h"


@implementation Bouncer

+ (void) load
{
    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(applicationWillFinishLaunching:)
               name: NSApplicationWillFinishLaunchingNotification
             object: nil];
}

+ (void) applicationWillFinishLaunching: (NSNotification *) notification
{
    BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:
        @"org.dribin.dave.TheBouncer.disabled"];
    if (disabled)
        return;
    
    static Bouncer * bouncer = nil;
    if (bouncer != nil)
        return;
    
    bouncer = [[self alloc] init];
    [bouncer installDO];
}

- (void) installDO;
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSString * processName = [processInfo processName];
    
    NSString * connectionName = [NSString stringWithFormat:
        @"DDBouncerVictimDO %@", processName];
    NSLog(@"Registering %@", connectionName);
    mConnection = [[NSConnection defaultConnection] retain];
    [mConnection setRootObject: self];
    [mConnection registerName: connectionName];
        
    NSLog(@"Sending DDBouncerDOAvailable");
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        processName, @"Name",
        [mainBundle bundlePath], @"BundlePath",
        connectionName, @"ConnectionName",
        nil];

    [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName: @"DDBouncerDOAvailable"
                  object: nil
                userInfo: userInfo];
    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(removeDO:)
               name: NSApplicationWillTerminateNotification
             object: nil];
    
}

- (void) removeDO: (NSNotification *) notification;
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSString * processName = [processInfo processName];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        processName, @"Name",
        nil];
    
    NSLog(@"Sending DDBouncerDOGone");
    [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName: @"DDBouncerDOGone"
                  object: nil
                userInfo: userInfo];
}

- (void) bounce;
{
    [NSApp cancelUserAttentionRequest: NSInformationalRequest];
    [NSApp cancelUserAttentionRequest: NSCriticalRequest];

    [NSApp requestUserAttention: NSInformationalRequest];
    [NSTimer scheduledTimerWithTimeInterval: 0.50
                                     target: self
                                   selector: @selector(cancelInformational)
                                   userInfo: nil
                                    repeats: NO];
}

- (void) cancelInformational
{
    [NSApp cancelUserAttentionRequest: NSInformationalRequest];
}

- (void) bounceCritical;
{
    [NSApp cancelUserAttentionRequest: NSInformationalRequest];
    [NSApp cancelUserAttentionRequest: NSCriticalRequest];

    [NSApp requestUserAttention: NSCriticalRequest];
}

@end
