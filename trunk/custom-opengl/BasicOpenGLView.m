//
//  BasicOpenGLView.m
//  DDCustomOpenGL
//
//  Created by Dave Dribin on 10/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BasicOpenGLView.h"

static const int FULL_SCREEN_WIDTH = 640;
static const int FULL_SCREEN_HEIGHT = 480;

@interface BasicOpenGLView (Private)

- (void) updateAnimation;

@end

@implementation BasicOpenGLView

-(id) initWithFrame: (NSRect) frameRect
{
	NSOpenGLPixelFormatAttribute colorSize = 24;
	NSOpenGLPixelFormatAttribute depthSize = 16;
	
    // pixel format attributes for the view based (non-fullscreen) NSOpenGLContext
    NSOpenGLPixelFormatAttribute windowedAttributes[] =
	{
        // specifying "NoRecovery" gives us a context that cannot fall back to the software renderer
		// this makes the view-based context a compatible with the fullscreen context,
		// enabling us to use the "shareContext" feature to share textures, display lists, and other OpenGL objects between the two
        NSOpenGLPFANoRecovery,
        // attributes common to fullscreen and window modes
        NSOpenGLPFAColorSize, colorSize,
        NSOpenGLPFADepthSize, depthSize,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        0
    };
	NSOpenGLPixelFormat * windowedPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: windowedAttributes];
    [windowedPixelFormat autorelease];
    
	self = [super initWithFrame: frameRect pixelFormat: windowedPixelFormat];
    if (self == nil)
        return nil;
    
    // pixel format attributes for the full screen NSOpenGLContext
    NSOpenGLPixelFormatAttribute fullScreenAttributes[] =
	{
        // specifying "NoRecovery" gives us a context that cannot fall back to the software renderer
		// this makes the view-based context a compatible with the fullscreen context,
		// enabling us to use the "shareContext" feature to share textures, display lists, and other OpenGL objects between the two
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
        // attributes common to fullscreen and window modes
        NSOpenGLPFAColorSize, colorSize,
        NSOpenGLPFADepthSize, depthSize,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        0
    };
	NSOpenGLPixelFormat * fullScreenPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: fullScreenAttributes];
    [fullScreenPixelFormat autorelease];
    [self setFullScreenPixelFormat: fullScreenPixelFormat];
    
    [self setFullScreenWidth: FULL_SCREEN_WIDTH height: FULL_SCREEN_HEIGHT];
    
    mRect = NSMakeRect(0, 0, 160, 120);
    mDirX = mDirY = 1;
    mLastTime = 0.0f;
    
    return self;
}

- (void) prepareOpenGL
{
    NSLog(@"prepareOpenGL");
    long swapInt = 1;
    
    // set to vbl sync
    [[self openGLContext] setValues:&swapInt
                       forParameter:NSOpenGLCPSwapInterval];
	// init GL stuff here
	glEnable(GL_DEPTH_TEST);
    
	glShadeModel(GL_SMOOTH);    
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CCW);
	glPolygonOffset(1.0f, 1.0f);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void) update
{
    [super update];
}

- (void) resize: (NSRect) bounds
{
	glViewport(bounds.origin.x, bounds.origin.y, bounds.size.width,
               bounds.size.height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, bounds.size.width, 0, bounds.size.height, 0, 1);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

- (void) drawFrame
{
    NSRect bounds = [self currentBounds];
    [self resize: bounds];
    [self updateAnimation];
    
	// clear our drawable
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    NSRect rect;
    float z;
    
    z = 0.0f;
    rect = NSMakeRect(0.0f, 0.0f, FULL_SCREEN_WIDTH - 1, FULL_SCREEN_HEIGHT - 1);
    
    glColor3f(1.0f, 0.0f, 0.0f);
    glBegin(GL_LINES);
    glVertex3f(rect.origin.x,       rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        rect.origin.y,      z);

    glVertex3f(NSMaxX(rect),        rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        NSMaxY(rect),       z);

    glVertex3f(NSMaxX(rect),        NSMaxY(rect),       z);
    glVertex3f(rect.origin.x,       NSMaxY(rect),       z);

    glVertex3f(rect.origin.x,       NSMaxY(rect),       z);
    glVertex3f(rect.origin.x,       rect.origin.y,      z);
    glEnd();

    z = 0.0f;
    rect = mRect;
    glColor3f(0.0f, 0.0f, 1.0f);
    glBegin(GL_POLYGON);
    glVertex3f(rect.origin.x,       rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        NSMaxY(rect),       z);
    glVertex3f(rect.origin.x,       NSMaxY(rect),       z);
    glEnd();
}

@end

@implementation BasicOpenGLView (Private)

- (void) updateAnimation;
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();

    if (mLastTime == 0.0f)
    {
        mRect.origin = NSMakePoint(0.0f, 0.0f);
        mLastTime = currentTime;
        return;
    }
    
    CFAbsoluteTime diff = currentTime - mLastTime;
    mRect.origin.x += 250 * mDirX * diff;
    mRect.origin.y += 300 * mDirY * diff;
    
    if (mRect.origin.x < 0)
    {
        mDirX = 1;
        mRect.origin.x = 0;
    }
    if (NSMaxX(mRect) > FULL_SCREEN_WIDTH)
    {
        mDirX = -1;
        mRect.origin.x = FULL_SCREEN_WIDTH - mRect.size.width;
    }
    if (mRect.origin.y < 0)
    {
        mDirY = 1;
        mRect.origin.y = 0;
    }
    if (NSMaxY(mRect) > FULL_SCREEN_HEIGHT)
    {
        mDirY = -1;
        mRect.origin.y = FULL_SCREEN_HEIGHT - mRect.size.height;
    }
    
    mLastTime = currentTime;
    return;
}

@end

