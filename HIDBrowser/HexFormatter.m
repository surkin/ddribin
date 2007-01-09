//
//  HexFormatter.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HexFormatter.h"


@implementation HexFormatter

+ (NSString*)format:(long)number;
{
    return [NSString stringWithFormat: @"0x%02X", number];
}


- (NSString *)stringForObjectValue:(id)anObject {
	return [HexFormatter format:[anObject longValue]];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	return NO;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject]] autorelease];
}


@end
