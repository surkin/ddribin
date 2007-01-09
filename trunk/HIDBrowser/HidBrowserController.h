//
//  HidBrowserController.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HidBrowserController : NSObject
{
    NSArray * mDevices;
}

- (NSArray *) devices;

@end
