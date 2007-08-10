//
//  InteractiveController.h
//  TheBouncer
//
//  Created by Dave Dribin on 8/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QTMovieView;
@class QTMovie;
@class BouncerController;
@class BouncerView;

@interface InteractiveController : NSWindowController
{
    IBOutlet BouncerController * mController;
    IBOutlet BouncerView * mBouncerView;
    NSArray * mKeyboards;
    
    NSMachPort * mNotificationPort;

    QTMovie * mMovie;
    NSTimer * mPlaybackTimer;
    NSMutableArray * mPlaybackQueue;
    unsigned mCurrentPlaybackIndex;
    BOOL mRecording;
}

- (IBAction) savePlayback: (id) sender;
- (IBAction) openPlayback: (id) sender;

- (IBAction) recordPlayback: (id) sender;
- (IBAction) clearPlaybackQueue: (id) sender;
- (IBAction) startPlayback: (id) sender;
- (IBAction) stopPlayback: (id) sender;

@end
