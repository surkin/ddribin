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

#define USE_CV_PIXEL_BUFFER 1

@interface BasicOpenGLView (Private)

- (CGImageRef) createImage;
- (void) loadTexture;

@end

@implementation BasicOpenGLView

-(id) initWithFrame: (NSRect) frameRect
{
    NSOpenGLPixelFormatAttribute colorSize = 32;
    NSOpenGLPixelFormatAttribute depthSize = 32;
    
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
    [self loadTexture];
    
    return self;
}

- (void) dealloc
{
    CVOpenGLTextureRelease(mTexture);
    [super dealloc];
}

- (void) prepareOpenGL: (NSOpenGLContext *) context;
{
    NSLog(@"prepareOpenGL");
    long swapInt = 1;
    
    // set to vbl sync
    [context setValues: &swapInt
          forParameter: NSOpenGLCPSwapInterval];
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

- (void) drawFrame
{
    NSRect bounds = [self currentBounds];
    [self resize: bounds];
    
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

#if 0
    z = 0.0f;
    rect = mRect;
    glColor3f(0.0f, 0.0f, 1.0f);
    glBegin(GL_POLYGON);
    glVertex3f(rect.origin.x,       rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        NSMaxY(rect),       z);
    glVertex3f(rect.origin.x,       NSMaxY(rect),       z);
    glEnd();
#else
    GLfloat vertices[4][2];
    GLfloat texCoords[4][2];
    
    glColor3f(1.0f, 1.0f, 1.0f);
    // Configure OpenGL to get vertex and texture coordinates from our two arrays
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    rect = mRect;
    // Top left
    vertices[0][0] = rect.origin.x;
    vertices[0][1] = rect.origin.y;
    // Bottom left
    vertices[1][0] = NSMaxX(rect);
    vertices[1][1] = rect.origin.y;
    // Bottom right
    vertices[2][0] = NSMaxX(rect);
    vertices[2][1] = NSMaxY(rect);
    // Top right
    vertices[3][0] = rect.origin.x;
    vertices[3][1] = NSMaxY(rect);
    
#if !USE_CV_PIXEL_BUFFER
    GLenum textureTarget = GL_TEXTURE_RECTANGLE_ARB;
#else
    GLenum textureTarget = CVOpenGLTextureGetTarget(mTexture);
#endif
    glEnable(textureTarget);
        
    glTexParameteri(textureTarget, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(textureTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    // Get the current texture's coordinates, bind the texture, and draw our rectangle
    rect.origin = NSMakePoint(0, 0);
    texCoords[0][0] = rect.origin.x;
    texCoords[0][1] = rect.origin.y;
    texCoords[1][0] = NSMaxX(rect);
    texCoords[1][1] = rect.origin.y;
    texCoords[2][0] = NSMaxX(rect);
    texCoords[2][1] = NSMaxY(rect);
    texCoords[3][0] = rect.origin.x;
    texCoords[3][1] = NSMaxY(rect);

#if !USE_CV_PIXEL_BUFFER    
    GLuint textureName = mTextureName;
#else
    GLuint textureName = CVOpenGLTextureGetName(mTexture);
#endif
    glBindTexture(textureTarget, textureName);
    glDrawArrays(GL_QUADS, 0, 4);
    glDisable(textureTarget);
#endif
}

@end

@implementation BasicOpenGLView (Private)

- (CGImageRef) createImage;
{
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    NSString * path = [myBundle pathForImageResource: @"image"];
    NSURL * url = [NSURL fileURLWithPath: path];
    CGImageSourceRef myImageSourceRef = CGImageSourceCreateWithURL((CFURLRef) url, nil);
    CGImageRef myImageRef = CGImageSourceCreateImageAtIndex (myImageSourceRef, 0, nil);
    CFRelease(myImageSourceRef);
    
    return myImageRef;
}

- (void) loadTexture;
{
    mTexture = NULL;
    
    CGImageRef myImageRef = [self createImage];
    size_t width = CGImageGetWidth(myImageRef);
    size_t height = CGImageGetHeight(myImageRef);
    CGRect rect = {{0, 0}, {width, height}};
    
#if !USE_CV_PIXEL_BUFFER
    NSLog(@"Create texture directly");
    
    void * myData = calloc(width * 4, height);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef myBitmapContext = CGBitmapContextCreate (myData, 
                                                          width, height, 8,
                                                          width*4, space, 
                                                          kCGImageAlphaPremultipliedFirst);

    //  Move the CG origin to the upper left of the port
    CGContextTranslateCTM( myBitmapContext, 0,
                           (float)(height) );
    
    //  Flip the y axis so that positive Y points down
    //  Note that this will cause text drawn with Core Graphics
    //  to draw upside down
    CGContextScaleCTM( myBitmapContext, 1.0, -1.0 );
    
    CGContextDrawImage(myBitmapContext, rect, myImageRef);
    CGContextRelease(myBitmapContext);

    [[self openGLContext] makeCurrentContext];
    glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, &mTextureName);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, mTextureName);
    glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, 
                    GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#if __BIG_ENDIAN__
    GLenum type = GL_UNSIGNED_INT_8_8_8_8_REV;
#else
    GLenum type = GL_UNSIGNED_INT_8_8_8_8;
#endif
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height,
                 0, GL_BGRA_EXT, type, myData);
    free(myData);

#else // USE_CV_PIXEL_BUFFER
    NSLog(@"Create texture with Core Video");

    CVReturn rc;
    int pixelFormat = k32ARGBPixelFormat;
    CVPixelBufferRef pixelBuffer;
    rc = CVPixelBufferCreate(NULL,
                             width,
                             height,
                             pixelFormat,
                             NULL, // pixelBufferAttributes
                             &pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void * baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef myBitmapContext = CGBitmapContextCreate(baseAddress, 
                                                         width, height, 8,
                                                         bytesPerRow, space, 
                                                         kCGImageAlphaPremultipliedFirst);
    //  Move the CG origin to the upper left of the port
    CGContextTranslateCTM( myBitmapContext, 0,
                           (float)(height) );
    
    //  Flip the y axis so that positive Y points down
    //  Note that this will cause text drawn with Core Graphics
    //  to draw upside down
    CGContextScaleCTM( myBitmapContext, 1.0, -1.0 );
    
    CGContextDrawImage(myBitmapContext, rect, myImageRef);
    CGContextRelease(myBitmapContext);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CVOpenGLTextureCacheRef textureCache;
    rc = CVOpenGLTextureCacheCreate(NULL, NULL,
                                    [[self openGLContext] CGLContextObj],
                                    [[self pixelFormat] CGLPixelFormatObj],
                                    NULL,
                                    &textureCache);
    
    rc = CVOpenGLTextureCacheCreateTextureFromImage(NULL,
                                                    textureCache,
                                                    pixelBuffer,
                                                    NULL,
                                                    &mTexture);
    CVOpenGLTextureCacheRelease(textureCache);
                                    
    
    
#endif

    CFRelease(myImageRef);
    mRect.size.width = width;
    mRect.size.height = height;
}

@end

