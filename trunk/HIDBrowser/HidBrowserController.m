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

@implementation HidBrowserController

- (void) awakeFromNib
{
    [self willChangeValueForKey: @"devices"];
    mDevices = [[DDHidDevice allDevices] retain];
    [self didChangeValueForKey: @"devices"];
    NSDictionary * properties = [[mDevices objectAtIndex: 1] properties];
    NSArray * elements =  [properties objectForKey: @"Elements"];
    NSLog(@"Elements: %d, %@", [elements count], [elements class]);
    // NSDictionary * subElements = [elements objectForKey: @"Elements"];
    // NSLog(@"Subelements: %d", [subElements count]);
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

- (DDHidElement *) selectedElement;
{
    DDHidDevice * selectedDevice = [self selectedDevice];
    if (selectedDevice == nil)
        return nil;
    
    NSIndexPath * indexPath = [mElementsController selectionIndexPath];
    NSArray * elements = [selectedDevice elements];
    DDHidElement * element = nil;
    unsigned i;
    for (i = 0; i < [indexPath length]; i++)
    {
        element = [elements objectAtIndex: [indexPath indexAtPosition: i]];
        elements = [element elements];
    }
    return element;
}

- (IBAction) press: (id) sender;
{
    DDHidDevice * device = [self selectedDevice];
    DDHidElement * element = [self selectedElement];
    NSLog(@"press: %@", [element usageDescription]);
    IOHIDDeviceInterface122** deviceInterface = [device deviceInterface];
    IOHIDElementCookie cookie = [element cookie];
    IOHIDEventStruct event;
    (*deviceInterface)->open(deviceInterface, kIOHIDOptionsTypeNone);
    HRESULT result = (*deviceInterface)->getElementValue(deviceInterface, 
                                                         cookie,
                                                         &event);
    NSLog(@"result: %d, value: %lx", result, event.value);
    (*deviceInterface)->close(deviceInterface);
    
}

@end

@interface DDHidDevice (HIDUsageTables)

- (NSString *) usageDescription;

@end

@implementation DDHidDevice (HIDUsageTables)


- (NSString *) usageDescription;
{
    DDHidUsageTables * usageTables = [DDHidUsageTables standardUsageTables];
    unsigned usagePage = [self usagePage];
    unsigned usage = [self usage];
    NSString * description =
        [usageTables descriptionForUsagePage: usagePage
                                       usage: usage];
    return [NSString stringWithFormat: @"%@ (0x%04X : 0x%04X)", description,
        usagePage, usage];
}

@end

@interface DDHidElement (HIDUsageTables)

- (NSString *) usageDescription;

@end

@implementation DDHidElement (HIDUsageTables)


- (NSString *) usageDescription;
{
    DDHidUsageTables * usageTables = [DDHidUsageTables standardUsageTables];
    unsigned usagePage = [self usagePage];
    unsigned usage = [self usage];
    NSString * description =
        [usageTables descriptionForUsagePage: usagePage
                                       usage: usage];
    return [NSString stringWithFormat: @"%@ (0x%04X : 0x%04X)", description,
        usagePage, usage];
}

@end
