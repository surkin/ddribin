//
//  DDHidUsageTables.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDHidUsageTables : NSObject
{
    NSDictionary * mLookupTables;
}

+ (DDHidUsageTables *) standardUsageTables;

- (id) initWithLookupTables: (NSDictionary *) lookupTables;

- (NSString *) descriptionForUsagePage: (unsigned) usagePage
                                 usage: (unsigned) usage;

@end
