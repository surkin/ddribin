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

// increase this number for more frequency bands
static UInt32 numberOfBandLevels = 4;
// for StereoMix - If using DeviceMix, you need to get the channel count of the device.
static UInt32 numberOfChannels = 2;
// NSLevelIndicators are set up to have this max value
static UInt8  maxLevelIndicatorValue = 20;


@implementation BouncerAppDelegate

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mVictims = [[NSMutableArray alloc] init];
    // allocate memory for the QTAudioFrequencyLevels struct and set it up
    // depending on the number of channels and frequency bands you want    
    mFreqResults = malloc(offsetof(QTAudioFrequencyLevels, level[numberOfBandLevels * numberOfChannels]));
    
    mFreqResults->numChannels = numberOfChannels;
    mFreqResults->numFrequencyBands = numberOfBandLevels;
    
    return self;
}

- (void) progressProc;
{
    NSLog(@"progressProc");
}

pascal OSErr myMovieProgressProc(Movie theMovie, short theMessage, short theOperation, Fixed thePercentDone, long refcon)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    BouncerAppDelegate * controller = (BouncerAppDelegate *) refcon;
    [controller progressProc];
    
    [pool release];
    return noErr;
}

- (void) awakeFromNib;
{
    [mVictimsTable setDoubleAction: @selector(bounceSelectedVictims:)];
    
    QTMovie * movie = [mMovieView movie];
#if 0
    [movie setDelegate: self];
#elif 0
    MovieProgressUPP movieProgressUPP = NewMovieProgressUPP(myMovieProgressProc);
    if (movieProgressUPP != NULL)
    {
        SetMovieProgressProc([movie quickTimeMovie], movieProgressUPP,
                             (long) self);
    }
#else
    SetMovieAudioFrequencyMeteringNumBands(
        [movie quickTimeMovie], kQTAudioMeter_StereoMix, &numberOfBandLevels);

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

- (void) movieTimerx: (NSTimer *) timer
{
    QTMovie * movie = [timer userInfo];

    GetMovieAudioFrequencyLevels([movie quickTimeMovie], kQTAudioMeter_StereoMix, mFreqResults);
    int i, j;
#if 1
    for (i = 0; i < mFreqResults->numChannels; i++)
    {
        for (j = 0; j < mFreqResults->numFrequencyBands; j++)
        {
            if (j >= [mVictims count])
                continue;
            
            BouncerVictim * victim = [mVictims objectAtIndex: j];
                // the frequency levels are Float32 values between 0. and 1.
            Float32 value = (mFreqResults->level[(i * mFreqResults->numFrequencyBands) + j]) * maxLevelIndicatorValue;
            if (value > 15.0)
                [victim bounce];
        }
    }
#endif
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

@end
