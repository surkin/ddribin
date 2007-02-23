//
//  HexFormatter.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BoolFormatter.h"


@implementation BoolFormatter

- (id)initWithLables:(id)_l {
    if ((self = [super init]) != nil) {
        self->labels = [_l retain];
    }
    return self;
}

- (void)dealloc {
    [self->labels release];
    [super dealloc];
}

- (BOOL) boolForObjectValue: (id) object
{
    BOOL result;
    if ([object respondsToSelector: @selector(boolValue)])
        result = [object boolValue] ? YES : NO;
    else
        result = NO;
    return result;
}

- (NSString *)stringForObjectValue:(id)_obj
{
    NSString *str;
    
    if ([self boolForObjectValue: _obj])
        str = @"Yes";
    else
        str = @"No";

    return (self->labels != nil)
        ? (NSString *)[self->labels valueForKey:str] : str;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
                                 withDefaultAttributes:(NSDictionary *)defaultAttributes
{
    NSDictionary * yesAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor redColor], NSBackgroundColorAttributeName,
        nil];
    NSDictionary * attributes = defaultAttributes;
    if ([self boolForObjectValue: anObject])
        attributes = yesAttributes;
    
    NSAttributedString * string =
        [[NSAttributedString alloc] initWithString: [self stringForObjectValue: anObject]
                                        attributes: attributes];
    [string autorelease];
    return string;
}

@end
