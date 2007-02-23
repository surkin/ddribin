//
//  ButtonState.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ButtonState : NSObject
{
    NSString * mName;
    BOOL mPressed;
}

- (NSString *) name;

- (BOOL) pressed;
- (void) setPressed: (BOOL) flag;

@end
