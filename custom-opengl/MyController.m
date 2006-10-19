//
//  MyController.m
//  DDCustomOpenGL
//
//  Created by Dave Dribin on 10/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MyController.h"


@implementation MyController

- (void) applicationDidFinishLaunching: (NSNotification*) notification;
{
    NSWindow * window = [mView window];
    [window center];
    [window makeKeyAndOrderFront: nil];    
    [mView startAnimation];
}

- (void) applicationWillTerminate: (NSNotification *) notification;
{
    [mView setFullScreen: false];
}


- (void) setFullScreen: (BOOL) fullScreen;
{
    [mView setFullScreen: fullScreen];
}

- (BOOL) fullScreen;
{
    return [mView fullScreen];
}

- (IBAction) nullAction: (id) sender;
{
}

@end
