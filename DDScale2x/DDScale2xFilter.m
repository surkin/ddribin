//
//  DDScale2xFilter.m
//  CIHazeFilterSample
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDScale2xFilter.h"


static CIKernel * sScale2xKernel = nil;

@implementation DDScale2xFilter

#if STANDALONE
+ (void) initialize
{
    [CIFilter registerFilterName: @"DDScale2x"  constructor: self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                     
                     @"Scale 2x",                       kCIAttributeFilterDisplayName,
                     
                     [NSArray arrayWithObjects:
                         kCICategoryColorAdjustment, kCICategoryVideo, kCICategoryStillImage,
                         kCICategoryInterlaced, kCICategoryNonSquarePixels,
                         nil],                              kCIAttributeFilterCategories,
                                          
                     nil]];
}

+ (CIFilter *) filterWithName: (NSString *) name
{
    CIFilter  *filter;
    
    filter = [[self alloc] init];
    return [filter autorelease];
}
#endif

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    if (sScale2xKernel == nil)
    {
        NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
        NSString * kernelFile = [myBundle pathForResource: @"DDScale2x"
                                                   ofType: @"cikernel"];
        NSString * code = [NSString stringWithContentsOfFile: kernelFile];
        NSArray * kernels = [CIKernel kernelsWithString: code];
        sScale2xKernel = [[kernels objectAtIndex: 0] retain];
    }
    
    return self;
}

- (NSDictionary *) customAttributes;
{
    return [NSDictionary dictionary];
}

#if 0
- (CGRect)regionOf:(int)samplerIndex destRect:(CGRect)r userInfo:img
{
    return [img extent];
}
#endif

- (CIImage *) outputImage;
{
    NSDictionary * samplerOptions = [NSDictionary dictionaryWithObjectsAndKeys:
        kCISamplerFilterNearest, kCISamplerFilterMode,
        // kCISamplerFilterLinear, kCISamplerFilterMode,
        nil];
    CISampler * src = [CISampler samplerWithImage: inputImage
                                          options: samplerOptions];
    const float scale = 2.0;
    CGRect e = [inputImage extent];
    NSArray * extent = [NSArray arrayWithObjects:
        [NSNumber numberWithInt: e.origin.x], [NSNumber numberWithInt: e.origin.y],
        [NSNumber numberWithInt: e.size.width*scale], [NSNumber numberWithInt: e.size.height*scale],
        nil];

    // [sScale2xKernel setROISelector: @selector(regionOf:destRect:userInfo:)];

    NSArray * arguments = [NSArray arrayWithObjects:
        src, @"definition", extent, nil];
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
        extent, kCIApplyOptionExtent,
        // [src definition], kCIApplyOptionDefinition,
        // inputImage, kCIApplyOptionUserInfo,
        nil];

    CIImage * output = [self apply: sScale2xKernel
                         arguments: arguments
                           options: options];
    return output;
}    

@end
