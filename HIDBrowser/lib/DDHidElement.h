//
//  DDHidElement.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDHidElement : NSObject
{
    NSDictionary * mProperties;
    DDHidElement * mChildren;
}

+ (NSArray *) elementsWithPropertiesArray: (NSArray *) propertiesArray;

+ (DDHidElement *) elementWithProperties: (NSDictionary *) properties;

- (id) initWithProperties: (NSDictionary *) properties;

- (NSDictionary *) properites;

- (NSString *) stringForKey: (NSString *) key;

- (unsigned) cookie;
- (unsigned) usage;
- (unsigned) usagePage;
- (NSString *) usageDescription;
- (NSArray *) elements;

@end
