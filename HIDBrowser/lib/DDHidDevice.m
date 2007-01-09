//
//  DDHidDevice.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidDevice.h"

@interface NSDictionary (IOHelpers)

- (NSString *) stringForString: (const char *) key;
- (long) longForString: (const char *) key;

@end

@implementation NSDictionary (IOHelpers)

- (NSString *) stringForString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithCString: key];
    return [self objectForKey: objcKey];
}

- (long) longForString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithCString: key];
    NSNumber * number =  [self objectForKey: objcKey];
    return [number longValue];
}

@end

@implementation DDHidDevice

- (id) initWithDevice: (io_object_t) device;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHidDevice = device;

    kern_return_t result;
    CFMutableDictionaryRef properties;
    result = IORegistryEntryCreateCFProperties(mHidDevice, &properties,
                                               kCFAllocatorDefault, kNilOptions);
    if (result != KERN_SUCCESS)
        return nil;

    mProperties = (NSMutableDictionary *) properties;
    mProductName = [[mProperties stringForString: kIOHIDProductKey] retain];
    mManufacturer = [[mProperties stringForString: kIOHIDManufacturerKey] retain];
    mTransport = [[mProperties stringForString: kIOHIDTransportKey] retain];
    mSerialNumber = [[mProperties stringForString: kIOHIDSerialNumberKey] retain];
    mVendorId = [mProperties longForString: kIOHIDVendorIDKey];
    mProductId = [mProperties longForString: kIOHIDProductIDKey];
    mVersion = [mProperties longForString: kIOHIDVersionNumberKey];
    mUsagePage = [mProperties longForString: kIOHIDPrimaryUsagePageKey];
    mUsage = [mProperties longForString: kIOHIDPrimaryUsageKey];
    
    return self;
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
    return mProductName; 
}

//=========================================================== 
// - manufacturer
//=========================================================== 
- (NSString *) manufacturer
{
    return mManufacturer; 
}

//=========================================================== 
// - serialNumber
//=========================================================== 
- (NSString *) serialNumber
{
    return mSerialNumber; 
}

//=========================================================== 
// - transport
//=========================================================== 
- (NSString *) transport
{
    return mTransport; 
}

//=========================================================== 
// - vendorId
//=========================================================== 
- (long) vendorId
{
    return mVendorId;
}

//=========================================================== 
// - productId
//=========================================================== 
- (long) productId
{
    return mProductId;
}

//=========================================================== 
// - version
//=========================================================== 
- (long) version
{
    return mVersion;
}

//=========================================================== 
// - usbLocationId
//=========================================================== 
- (long) usbLocationId
{
    return mUsbLocationId;
}

//=========================================================== 
// - usagePage
//=========================================================== 
- (long) usagePage
{
    return mUsagePage;
}

//=========================================================== 
// - usage
//=========================================================== 
- (long) usage
{
    return mUsage;
}


@end
