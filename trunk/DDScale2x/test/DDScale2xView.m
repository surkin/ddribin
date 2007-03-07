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
    
    NSURL       *url;
    
    [DDScale2xFilter class];
    
    url      = [NSURL fileURLWithPath: [[NSBundle mainBundle]
            pathForResource: @"liquidk-1s"  ofType: @"png"]];
    inputImage = [[CIImage imageWithContentsOfURL: url] retain];
    filter   = [CIFilter filterWithName: @"DDScale2x"
                          keysAndValues: @"inputImage", inputImage, nil];
    [filter retain];
    
    
    return self;
}

- (void)drawRect: (NSRect)rect
{
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	
	if (context != nil)
    {
        CIImage * outputImage = [filter valueForKey: @"outputImage"];
        CGRect outputRect = [outputImage extent];
        CGPoint origin = CGPointMake(NSMinX(rect), NSMinY(rect));
        
		[context drawImage: outputImage
                   atPoint: origin  fromRect: outputRect];
    }
}

@end
