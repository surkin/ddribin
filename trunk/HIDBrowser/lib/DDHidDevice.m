//
//  DDHidDevice.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidDevice.h"
#import "DDHidElement.h"
#import "DDHidUsageTables.h"
#import "NSDictionary+AccessHelpers.h"

@interface DDHidDevice (Private)

- (BOOL) initProperties;
- (BOOL) createDeviceInterface;

@end

@implementation DDHidDevice

- (id) initWithDevice: (io_object_t) device;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHidDevice = device;
    
    if (![self initProperties])
    {
        [self release];
        return nil;
    }
    
    if (![self createDeviceInterface])
    {
        [self release];
        return nil;
    }
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mProperties release];
    
    mProperties = nil;
    [super dealloc];
}

+ (NSArray *) allDevices;
{
	// Set up a matching dictionary to search the I/O Registry by class
	// name for all HID class devices
	CFMutableDictionaryRef hidMatchDictionary =
        IOServiceMatching(kIOHIDDeviceKey);
    
	// Now search I/O Registry for matching devices.
	io_iterator_t hidObjectIterator;
    IOReturn result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                   hidMatchDictionary,
                                                   &hidObjectIterator);
    if ((result != kIOReturnSuccess) || (hidObjectIterator == 0))
        return nil;
    
    NSMutableArray * devices = [NSMutableArray array];
    
    io_object_t hidDevice;
    while (hidDevice = IOIteratorNext(hidObjectIterator))
    {
        DDHidDevice * device = [[DDHidDevice alloc] initWithDevice: hidDevice];
        [device autorelease];
        
        [devices addObject: device];
    }
    
    IOObjectRelease(hidObjectIterator);
    
    return devices;
}

#pragma mark -

- (NSDictionary *) properties;
{
    return mProperties;
}

//=========================================================== 
// - productName
//=========================================================== 
- (NSString *) productName
{
    return [mProperties stringForString: kIOHIDProductKey]; 
}

//=========================================================== 
// - manufacturer
//=========================================================== 
- (NSString *) manufacturer
{
    return [mProperties stringForString: kIOHIDManufacturerKey];
}

//=========================================================== 
// - serialNumber
//=========================================================== 
- (NSString *) serialNumber
{
    return [mProperties stringForString: kIOHIDSerialNumberKey];
}

//=========================================================== 
// - transport
//=========================================================== 
- (NSString *) transport
{
    return [mProperties stringForString: kIOHIDTransportKey];
}

//=========================================================== 
// - vendorId
//=========================================================== 
- (long) vendorId
{
    return [mProperties longForString: kIOHIDVendorIDKey];
}

//=========================================================== 
// - productId
//=========================================================== 
- (long) productId
{
    return [mProperties longForString: kIOHIDProductIDKey];
}

//=========================================================== 
// - version
//=========================================================== 
- (long) version
{
    return [mProperties longForString: kIOHIDVersionNumberKey];
}

//=========================================================== 
// - usbLocationId
//=========================================================== 
- (long) usbLocationId
{
    return [mProperties longForString: kIOHIDLocationIDKey];
}

//=========================================================== 
// - usagePage
//=========================================================== 
- (long) usagePage
{
    return [mProperties longForString: kIOHIDPrimaryUsagePageKey];
}

//=========================================================== 
// - usage
//=========================================================== 
- (long) usage
{
    return [mProperties longForString: kIOHIDPrimaryUsageKey];
}

- (NSArray *) elements;
{
    return mElements;
}

@end


@implementation DDHidDevice (Private)

- (BOOL) initProperties;
{
    kern_return_t result;
    CFMutableDictionaryRef properties;
    result = IORegistryEntryCreateCFProperties(mHidDevice, &properties,
                                               kCFAllocatorDefault, kNilOptions);
    if (result != KERN_SUCCESS)
        return NO;
    
    mProperties = (NSMutableDictionary *) properties;
    NSArray * elementProperties = [mProperties objectForString: kIOHIDElementKey];
    mElements = [DDHidElement elementsWithPropertiesArray: elementProperties];
    [mElements retain];
    return YES;
}

- (BOOL) createDeviceInterface;
{
    return YES;
}

@end

