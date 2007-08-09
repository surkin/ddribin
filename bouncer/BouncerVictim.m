//
//  BouncerVictim.m
//  TheBouncer
//
//  Created by Dave Dribin on 8/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BouncerVictim.h"


@implementation BouncerVictim

- (id) initWithNoficationInfo: (NSDictionary *) userInfo;
{
    self = [super init];
    if (self == nil)
        return nil;
    

    mName = [[userInfo valueForKey: @"Name"] retain];

    NSString * fullPath = [userInfo valueForKey: @"BundlePath"];
    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    mIcon = [[workspace iconForFile: fullPath] retain];
    [mIcon setScalesWhenResized: YES];
    [mIcon setSize: NSMakeSize(16.0, 16.0)];
    
    NSString * connectionName = [userInfo valueForKey: @"ConnectionName"];
    mVictim = [[NSConnection rootProxyForConnectionWithRegisteredName: connectionName
                                                                 host: nil] retain];

    return self;
}

- (id) initWithWorkspaceApplication: (NSDictionary *) application;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    NSString * name = [application valueForKey: @"NSApplicationName"];
    NSString * connectionName = [NSString stringWithFormat:
        @"DDBouncerVictimDO %@", name];
        
    mVictim = [[NSConnection rootProxyForConnectionWithRegisteredName: connectionName
                                                                 host: nil] retain];
    if (mVictim == nil)
    {
        [self release];
        return nil;
    }
    
    mName = [name retain];
    
    NSString * fullPath = [application valueForKey: @"NSApplicationPath"];
    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    mIcon = [[workspace iconForFile: fullPath] retain];
    [mIcon setScalesWhenResized: YES];
    [mIcon setSize: NSMakeSize(16.0, 16.0)];
    
    return self;
}

- (NSString *) name;
{
    return mName;
}

- (NSImage *) icon;
{
    return mIcon;
}

- (void) bounce;
{
    [mVictim bounce];
}

//=========================================================== 
// - effect
//=========================================================== 
- (BOOL) effect
{
    return mEffect;
}

//=========================================================== 
// - setEffect:
//=========================================================== 
- (void) setEffect: (BOOL) flag
{
    mEffect = flag;
}

@end
