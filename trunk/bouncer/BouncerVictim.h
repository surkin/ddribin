//
//  BouncerVictim.h
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BouncerVictimDO.h"

@interface BouncerVictim : NSObject
{
    NSString * mName;
    NSImage * mIcon;
    BOOL mEffect;
    id<BouncerVictimDO> mVictim;
}

- (id) initWithNoficationInfo: (NSDictionary *) userInfo;

- (id) initWithWorkspaceApplication: (NSDictionary *) application;

- (NSString *) name;

- (NSImage *) icon;

- (void) bounce;

- (BOOL) effect;
- (void) setEffect: (BOOL) flag;

@end
