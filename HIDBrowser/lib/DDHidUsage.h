//
//  DDHidUsage.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDHidUsage : NSObject
{
    unsigned mUsagePage;
    unsigned mUsageId;
}

+ (DDHidUsage *) usageWithUsagePage: (unsigned) usagePage
                            usageId: (unsigned) usageId;

- (id) initWithUsagePage: (unsigned) usagePage
                 usageId: (unsigned) usageId;

- (unsigned) usagePage;

- (unsigned) usageId;

- (NSString *) usageName;

- (NSString *) usageNameWithIds;

- (NSString *) description;

@end
