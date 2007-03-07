//
//  DDScale2xView.m
//  DDScale2x
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDScale2xView.h"
#import "DDScale2xFilter.h"

@implementation DDScale2xView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    [DDScale2xFilter class];
    // [CIPlugIn loadAllPlugIns];
    
    NSURL * url = [NSURL fileURLWithPath: [[NSBundle mainBundle]
            pathForResource: @"liquidk-1s"  ofType: @"png"]];
    inputImage = [[CIImage imageWithContentsOfURL: url] retain];
    NSLog(@"Names: %@", [CIFilter filterNamesInCategory: kCICategoryGeometryAdjustment]);
    filter   = [CIFilter filterWithName: @"DDScale2xFilter"];
    [filter setValue: inputImage forKey: @"inputImage"];
    [filter retain];
    
    
    return self;
}

- (void)drawRect: (NSRect)rect
{
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	
	if (context != nil)
    {
        CIImage * outputImage = [filter valueForKey: @"outputImage"];
        CGRect outputExtent = [outputImage extent];
        NSLog(@"outputRect: %d", CGRectIsInfinite(outputExtent));
        CGPoint origin = CGPointMake(NSMinX(rect), NSMinY(rect));
        
		[context drawImage: outputImage
                   atPoint: origin  fromRect: outputExtent];
    }
}

@end
