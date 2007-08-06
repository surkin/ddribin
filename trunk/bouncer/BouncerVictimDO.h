/*
 *  BouncerVictimDO.h
 *  TheBouncer
 *
 *  Created by Dave Dribin on 8/6/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

@protocol BouncerVictimDO <NSObject>

- (oneway void) bounce;
- (oneway void) bounceCritical;

@end
