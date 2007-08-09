//
//  BouncerAppDelegate.h
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface BouncerController : NSObject
{
    IBOutlet NSArrayController * mVictimsController;
    IBOutlet NSTableView * mVictimsTable;
    
    NSMutableArray * mVictims;
}

- (NSArray *) victims;

- (IBAction) bounceSelectedVictims: (id) sender;

- (IBAction) bounceInPattern: (id) sender;

@end
