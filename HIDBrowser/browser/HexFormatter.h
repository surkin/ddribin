//
//  HexFormatter.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HexFormatter : NSFormatter {

}

+ (NSString*)format:(long)number;

@end
