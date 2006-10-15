//
//  BasicOpenGLView.h
//  DDCustomOpenGL
//
//  Created by Dave Dribin on 10/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DDCustomOpenGLView.h"

@interface BasicOpenGLView : DDCustomOpenGLView
{
    CFAbsoluteTime mLastTime;
    NSRect mRect;
    int mDirX;
    int mDirY;
    GLuint mTextureName;
}

@end
