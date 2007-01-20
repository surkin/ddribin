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
    unsigned index = [mDevicesController selectionIndex];
    if (index == NSNotFound)
        return nil;
    return [mDevices objectAtIndex: index];}

- (DDHidElement *) elementAtIndexPath: (NSIndexPath *) indexPath
                            forDevice: (DDHidDevice *) device;
{
    NSArray * elements = [device elements];
    DDHidElement * element = nil;
    unsigned i;
    for (i = 0; i < [indexPath length]; i++)
    {
        element = [elements objectAtIndex: [indexPath indexAtPosition: i]];
        elements = [element elements];
    }
    return element;
}

- (DDHidElement *) selectedElement;
{
    DDHidDevice * selectedDevice = [self selectedDevice];
    if (selectedDevice == nil)
        return nil;
    
    NSIndexPath * indexPath = [mElementsController selectionIndexPath];
    return [self elementAtIndexPath: indexPath forDevice: selectedDevice];
}

- (NSArray *) selectedElements;
{
    NSMutableArray * elements = [NSMutableArray array];
    DDHidDevice * selectedDevice = [self selectedDevice];
    if (selectedDevice == nil)
        return elements;
    
    NSArray * indexPaths = [mElementsController selectionIndexPaths];
    NSIndexPath * indexPath;
    NSEnumerator * e = [indexPaths objectEnumerator];
    while (indexPath = [e nextObject])
    {
        DDHidElement * element = [self elementAtIndexPath: indexPath
                                                forDevice: selectedDevice];
        [elements addObject: element];
    }
    return elements;
}

- (IBAction) watchSelected: (id) sender;
{
    NSArray * selectedElements = [self selectedElements];
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
