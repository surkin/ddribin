//
//  Bouncer.h
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BouncerVictimDO.h"

@interface Bouncer : NSObject <BouncerVictimDO>
{
    NSConnection * mConnection;
}

- (void) installDO;

- (void) bounce;
- (void) bounceCritical;

@end
