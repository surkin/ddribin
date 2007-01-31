//
//  HidBrowserController.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HidBrowserController.h"
#import "DDHidUsageTables.h"
#import "DDHidDevice.h"
#import "DDHidElement.h"
#import "WatcherWindowController.h"

@implementation HidBrowserController


- (void) awakeFromNib
{
    [self willChangeValueForKey: @"devices"];
    mDevices = [[DDHidDevice allDevices] retain];
    [self didChangeValueForKey: @"devices"];
    
    [mWindow center];
    [mWindow makeKeyAndOrderFront: self];
#if 0
    NSEnumerator * e = [mDevices objectEnumerator];
    int i = 0;
    DDHidDevice * device;
    while (device = [e nextObject])
    {
        NSDictionary * properties = [device properties];
        [properties writeToFile: [NSString stringWithFormat: @"/tmp/device_%d.plist", i]
                     atomically: NO];
        i++;
    }
#endif
}

//=========================================================== 
// - devices
//=========================================================== 
- (NSArray *) devices
{
    return mDevices; 
}

- (DDHidDevice *) selectedDevice;
{
    NSArray * selectedDevices = [mDevicesController selectedObjects];
    if ([selectedDevices count] > 0)
        return [selectedDevices objectAtIndex: 0];
    else
        return nil;
}

- (IBAction) watchSelected: (id) sender;
{
    NSArray * selectedElements = [mElementsController selectedObjects];
    if ([selectedElements count] == 0)
        return;

    WatcherWindowController * controller =
        [[WatcherWindowController alloc] init];
    [controller setDevice: [self selectedDevice]];
    [controller setElements: selectedElements];
    [controller showWindow: self];
}

- (IBAction) exportPlist: (id) sender;
{
    DDHidDevice * selectedDevice = [self selectedDevice];
    if (selectedDevice == nil)
        return;

    NSSavePanel * panel = [NSSavePanel savePanel];
    
    /* set up new attributes */
    [panel setRequiredFileType: @"plist"];
    [panel setAllowsOtherFileTypes: NO];
    [panel setCanSelectHiddenExtension: YES];
    
    /* display the NSSavePanel */
    [panel beginSheetForDirectory: NSHomeDirectory()
                             file: @""
                   modalForWindow: [NSApp mainWindow]
                    modalDelegate: self
                   didEndSelector: @selector(exportPlistPanelDidEnd:returnCode:contextInfo:)
                      contextInfo: selectedDevice];
}

- (void) exportPlistPanelDidEnd: (NSSavePanel *) panel
                     returnCode: (int) returnCode
                    contextInfo: (void *) contextInfo;
{
    DDHidDevice * selectedDevice = contextInfo;

    /* if successful, save file under designated name */
    if (returnCode != NSOKButton)
        return;
    
    NSDictionary * deviceProperties = [selectedDevice properties];
    if (![deviceProperties writeToFile: [panel filename] atomically: YES])
        NSBeep();
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
