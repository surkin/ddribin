//
//  MyController.h
//  DDCustomOpenGL
//
//  Created by Dave Dribin on 10/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BasicOpenGLView;

@interface MyController : NSObject
{
    IBOutlet BasicOpenGLView * mView;
}

- (void) setFullScreen: (BOOL) fullScreen;
- (BOOL) fullScreen;

- (IBAction) nullAction: (id) sender;

@end
