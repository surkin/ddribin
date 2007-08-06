//
//  BouncerAppDelegate.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BouncerAppDelegate.h"
#import "BouncerVictim.h"
#import <unistd.h>

@implementation BouncerAppDelegate

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mVictims = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) awakeFromNib;
{
    [mVictimsTable setDoubleAction: @selector(bounceSelectedVictims:)];
}

- (void) applicationDidFinishLaunching: (NSNotification *) notification;
{
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(bouncerDOAvailable:)
               name: @"DDBouncerDOAvailable"
             object: nil];
}

- (void) bouncerDOAvailable: (NSNotification *) notification;
{
    NSDictionary * userInfo = [notification userInfo];
    NSLog(@"bouncerDOAvailable: %@", userInfo);
    
    BouncerVictim * victim = [[BouncerVictim alloc] initWithNoficationInfo: userInfo];
    [victim autorelease];
    [self willChangeValueForKey: @"victims"];
    [mVictims addObject: victim];
    [self didChangeValueForKey: @"victims"];
}

- (NSArray *) victims;
{
    return mVictims;
}

- (IBAction) bounceSelectedVictims: (id) sender;
{
    if ((sender == mVictimsTable) && ([mVictimsTable clickedRow] == -1))
        return;
    
    NSArray * selectedVictims = [mVictimsController selectedObjects];
    [selectedVictims makeObjectsPerformSelector: @selector(bounce)];
}

- (IBAction) bounceInPattern: (id) sender;
{
    useconds_t intervals[] =
    {
        500000,
        500000,
        500000,
        500000,
        750000,

        0,
        500000,

        0,
        750000,

        0,
        500000,

        0,
        0,
    };
    
    int count = sizeof(intervals)/sizeof(useconds_t);
    
    int i;
    for (i = 0; i < count; i++)
    {
        if (i == [mVictims count])
            break;
        
        BouncerVictim * victim = [mVictims objectAtIndex: i];
        [victim bounce];
        if (intervals[i] > 0)
            usleep(intervals[i]);
    }
    
}

@end
