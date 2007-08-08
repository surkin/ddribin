//
//  BouncerAppDelegate.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <unistd.h>
#import <QuickTime/QuickTime.h>
#import <unistd.h>
#import "BouncerAppDelegate.h"
#import "BouncerVictim.h"

@interface BouncerAppDelegate (Private)

- (void) findExistingVictims;

@end

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
    [self findExistingVictims];
    
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    NSString * composition = [myBundle pathForResource: @"icons"
                                                ofType: @"qtz"];
    [mQCView loadCompositionFromFile: composition];
    
    QTMovie * movie = [mMovieView movie];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(movieTimeDidChange:)
                                                 name: QTMovieTimeDidChangeNotification
                                               object: movie];

#if 0
    [NSTimer scheduledTimerWithTimeInterval: 0.1
                                     target: self 
                                   selector: @selector(movieTimer:)
                                   userInfo: movie
                                    repeats: YES];
#endif
}

- (void) applicationDidFinishLaunching: (NSNotification *) notification;
{
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(bouncerDOAvailable:)
               name: @"DDBouncerDOAvailable"
             object: nil];

    [[NSDistributedNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(bouncerDOGone:)
               name: @"DDBouncerDOGone"
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
    [self updateQCIcons];
}

- (void) bouncerDOGone: (NSNotification *) notification;
{
    NSDictionary * userInfo = [notification userInfo];
    NSLog(@"bouncerDOGone: %@", userInfo);
    NSString * name = [userInfo valueForKey: @"Name"];
    NSMutableIndexSet * indexes = [NSMutableIndexSet indexSet];
    for (int i = 0; i < [mVictims count]; i++)
    {
        BouncerVictim * victim = [mVictims objectAtIndex: i];
        if ([[victim name] isEqualToString: name])
        {
            [indexes addIndex: i];
        }
    }
    [self willChangeValueForKey: @"victims"];
    [mVictims removeObjectsAtIndexes: indexes];
    [self didChangeValueForKey: @"victims"];
    [self updateQCIcons];

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

- (void) movieTimeDidChange: (NSNotification *) notification;
{
    NSLog(@"time did change");
}

- (BOOL) movieShouldTask_: (QTMovie *) movie
{
#if 0
    static int currentVictim = 0;
    static NSTimeInterval lastTime = 0;
    
    QTTime time = [movie currentTime];
    NSTimeInterval interval;
    QTGetTimeInterval(time, &interval);
    
    if ((interval - lastTime) > 0.5)
    {
        BouncerVictim * victim = [mVictims objectAtIndex: currentVictim];
        [victim bounce];
        lastTime = interval;
        currentVictim = (currentVictim + 1) % [mVictims count];
    }
#endif

    return YES;
}

- (void) movieTimer: (NSTimer *) timer
{
    QTMovie * movie = [timer userInfo];
    static int currentVictim = 0;
    static NSTimeInterval lastTime = 0;
    
    QTTime time = [movie currentTime];
    NSTimeInterval interval;
    QTGetTimeInterval(time, &interval);
    
    if ((interval - lastTime) > 1.0)
    {
        if ([mVictims count] > 0)
        {
            BouncerVictim * victim = [mVictims objectAtIndex: currentVictim];
            [victim bounce];
            lastTime = interval;
            currentVictim = (currentVictim + 1) % [mVictims count];
        }
        else
        {
            currentVictim = 0;
        }
    }
}

- (void) updateQCIcons;
{
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 0; i < [mVictims count]; i++)
    {
        BouncerVictim * victim = [mVictims objectAtIndex: i];
        NSImage * icon = [victim icon];
        NSNumber * effect = [NSNumber numberWithInt: [victim effect]? 0 : 1];
        NSDictionary * item = [NSDictionary dictionaryWithObjectsAndKeys:
            icon, @"image",
            effect, @"effect",
            nil];
        
        [images addObject: item];
    }
    [mQCView setValue: images forInputKey: @"Images"];
}

@end


@implementation BouncerAppDelegate (Private)

- (void) findExistingVictims;
{
    NSArray * applications = [[NSWorkspace sharedWorkspace] launchedApplications];
    [self willChangeValueForKey: @"victims"];
    for (int i = 0; i < [applications count]; i++)
    {
        NSDictionary * application = [applications objectAtIndex: i];
        BouncerVictim * victim = [[BouncerVictim alloc] initWithWorkspaceApplication:
            application];
        if (victim == nil)
        {
            NSLog(@"Skipping %@", [application valueForKey: @"NSApplicationName"]);
        }
        else
        {
            [mVictims addObject: victim];
        }
    }
    [self didChangeValueForKey: @"victims"];
    [self updateQCIcons];
}

@end

