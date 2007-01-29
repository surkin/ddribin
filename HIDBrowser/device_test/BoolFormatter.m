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

- (NSString *)stringForObjectValue:(id)_obj
{
    NSString *str;
    
    if ([_obj respondsToSelector: @selector(boolValue)])
        str = [_obj boolValue] ? @"Yes" : @"No";
    else
        str = @"No";
    return (self->labels != nil)
        ? (NSString *)[self->labels valueForKey:str] : str;
}

@end
