//
//  DDHidDevice.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidDevice.h"
#import "DDHidUsage.h"
#import "DDHidElement.h"
#import "DDHidQueue.h"
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
    
    if ([self productId] == 0)
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
    if (mDeviceInterface != NULL)
    {
        (*mDeviceInterface)->close(mDeviceInterface);
        (*mDeviceInterface)->Release(mDeviceInterface);
    }
    [mElementsByCookie release];
    [mElements release];
    [mUsages release];
    [mPrimaryUsage release];
    [mProperties release];
    
    mProperties = nil;
    mDeviceInterface = NULL;
    [super dealloc];
}

#pragma mark -
#pragma mark Finding Devices

+ (NSArray *) allDevices;
{
	// Set up a matching dictionary to search the I/O Registry by class
	// name for all HID class devices
	CFMutableDictionaryRef hidMatchDictionary =
        IOServiceMatching(kIOHIDDeviceKey);
    return [self allDevicesMatchingCFDictionary: hidMatchDictionary
                                      withClass: [DDHidDevice class]];
}

+ (NSArray *) allDevicesMatchingUsagePage: (unsigned) usagePage
                                  usageId: (unsigned) usageId
                                withClass: (Class) hidClass;
{
	// Set up a matching dictionary to search the I/O Registry by class
	// name for all HID class devices
	CFMutableDictionaryRef hidMatchDictionary =
        IOServiceMatching(kIOHIDDeviceKey);
    NSMutableDictionary * objcMatchDictionary =
        (NSMutableDictionary *) hidMatchDictionary;
    [objcMatchDictionary setObject: [NSNumber numberWithUnsignedInt: usagePage]
                         forString: kIOHIDDeviceUsagePageKey];
    [objcMatchDictionary setObject: [NSNumber numberWithUnsignedInt: usageId]
                         forString: kIOHIDDeviceUsageKey];
    return [self allDevicesMatchingCFDictionary: hidMatchDictionary
                                      withClass: hidClass];
}

+ (NSArray *) allDevicesMatchingCFDictionary: (CFDictionaryRef) matchDictionary
                                   withClass: (Class) hidClass;
{
	// Now search I/O Registry for matching devices.
	io_iterator_t hidObjectIterator;
    IOReturn result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                   matchDictionary,
                                                   &hidObjectIterator);
    if (result != kIOReturnSuccess)
        return nil;
    if (hidObjectIterator == 0)
        return [NSArray array];
    
    NSMutableArray * devices = [NSMutableArray array];
    
    io_object_t hidDevice;
    while (hidDevice = IOIteratorNext(hidObjectIterator))
    {
        DDHidDevice * device = [[hidClass alloc] initWithDevice: hidDevice];
        if (device == nil)
            continue;
        [device autorelease];
        
        [devices addObject: device];
    }
    
    IOObjectRelease(hidObjectIterator);
    
    // This makes sure the array return is consistent from run to run, 
    // assuming no new devices were added.
    [devices sortUsingSelector: @selector(compareByLocationId:)];
    
    return devices;
}

#pragma mark -
#pragma mark I/O Kit Objects

- (io_object_t) ioDevice;
{
    return mHidDevice;
}

- (IOHIDDeviceInterface122**) deviceInterface;
{
    return mDeviceInterface;
}

#pragma mark -
#pragma mark Operations

- (void) open;
{
    [self openWithOptions: kIOHIDOptionsTypeNone];
}

- (void) openWithOptions: (UInt32) options;
{
    (*mDeviceInterface)->open(mDeviceInterface, options);
}

- (void) close;
{
    (*mDeviceInterface)->close(mDeviceInterface);
}

- (DDHidQueue *) createQueueWithSize: (unsigned) size;
{
    IOHIDQueueInterface ** queue =
        (*mDeviceInterface)->allocQueue(mDeviceInterface);
    if (queue == NULL)
        return nil;
    return [[[DDHidQueue alloc] initWithHIDQueue: queue
                                            size: size] autorelease];
}

#pragma mark -
#pragma mark Properties

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
// - locationId
//=========================================================== 
- (long) locationId
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

- (DDHidElement *) elementForCookie: (IOHIDElementCookie) cookie;
{
    NSNumber * n = [NSNumber numberWithUnsignedInt: (unsigned) cookie];
    return [mElementsByCookie objectForKey: n];
}

- (DDHidUsage *) primaryUsage;
{
    return mPrimaryUsage;
}

- (NSArray *) usages;
{
    return mUsages;
}

- (NSComparisonResult) compareByLocationId: (DDHidDevice *) device;
{
    long myLocationId = [self locationId];
    long otherLocationId = [device locationId];
    if (myLocationId < otherLocationId)
        return NSOrderedAscending;
    else if (myLocationId > otherLocationId)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

@end


@implementation DDHidDevice (Private)

- (void) indexElements: (NSArray *) elements;
{
    NSEnumerator * e = [elements objectEnumerator];
    DDHidElement * element;
    while (element = [e nextObject])
    {
        NSNumber * n = [NSNumber numberWithUnsignedInt: [element cookieAsUnsigned]];
        [mElementsByCookie setObject: element
                              forKey: n];
        NSArray * children = [element elements];
        if (children != nil)
            [self indexElements: children];
    }
}

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
    
    unsigned usagePage = [mProperties unsignedIntForString: kIOHIDPrimaryUsagePageKey];
    unsigned usageId = [mProperties unsignedIntForString: kIOHIDPrimaryUsageKey];
    
    mPrimaryUsage = [[DDHidUsage alloc] initWithUsagePage: usagePage
                                                  usageId: usageId];
    mUsages = [[NSMutableArray alloc] init];
    
    NSArray * usagePairs = [mProperties objectForString: kIOHIDDeviceUsagePairsKey];
    NSEnumerator * e = [usagePairs objectEnumerator];
    NSDictionary * usagePair;
    while (usagePair = [e nextObject])
    {
        usagePage = [usagePair unsignedIntForString: kIOHIDDeviceUsagePageKey];
        usageId = [usagePair unsignedIntForString: kIOHIDDeviceUsageKey];
        DDHidUsage * usage = [DDHidUsage usageWithUsagePage: usagePage
                                                    usageId: usageId];
        [mUsages addObject: usage];
    }
    
    mElementsByCookie = [[NSMutableDictionary alloc] init];
    [self indexElements: mElements];
    
    return YES;
}

- (BOOL) createDeviceInterface;
{
	io_name_t				className;
	IOCFPlugInInterface**   plugInInterface = NULL;
	HRESULT					plugInResult = S_OK;
	SInt32					score = 0;
	IOReturn				ioReturnValue = kIOReturnSuccess;
	
	mDeviceInterface = NULL;
	
	ioReturnValue = IOObjectGetClass(mHidDevice, className);
	
	if (ioReturnValue != kIOReturnSuccess) {
		NSLog(@"Error: Failed to get class name.");
		return NO;
	}
	
    BOOL result = YES;
	ioReturnValue = IOCreatePlugInInterfaceForService(mHidDevice,
													  kIOHIDDeviceUserClientTypeID,
													  kIOCFPlugInInterfaceID,
													  &plugInInterface,
													  &score);
	if (ioReturnValue == kIOReturnSuccess)
	{
		//Call a method of the intermediate plug-in to create the device interface
		plugInResult = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), (LPVOID) &mDeviceInterface);
		
		if (plugInResult != S_OK) {
			NSLog(@"Error: Couldn't create HID class device interface");
            result = NO;
		}
		// Release
		if (plugInInterface) (*plugInInterface)->Release(plugInInterface);
	}
	return result;
}

@end

