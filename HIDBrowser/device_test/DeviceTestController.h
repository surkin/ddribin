//
//  DeviceTestController.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDHidQueue;

@interface DeviceTestController : NSObject
{
    NSArray * mMice;
    DDHidQueue * mQueue;
    
}

- (NSArray *) mice;
- (void) setMice: (NSArray *) newMice;

@end
