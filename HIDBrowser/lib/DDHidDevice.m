//
//  DDHidDevice.m
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDHidDevice.h"
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
    (*mDeviceInterface)->Release(mDeviceInterface);
    
    mProperties = nil;
    mDeviceInterface = NULL;
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

- (io_object_t) ioDevice;
{
    return mHidDevice;
}

- (IOHIDDeviceInterface122**) deviceInterface;
{
    return mDeviceInterface;
}

- (NSDictionary *) properties;
{
    return mProperties;
}

#pragma mark -

- (void) open;
{
    [self openWithOptions: kIOHIDOptionsTypeNone];
}

- (void) openWithOptions: (UInt32) options;
{
    (*mDeviceInterface)->open(mDeviceInterface, kIOHIDOptionsTypeNone);
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

- (DDHidElement *) elementForCookie: (IOHIDElementCookie) cookie;
{
    NSNumber * n = [NSNumber numberWithUnsignedInt: (unsigned) cookie];
    return [mElementsByCookie objectForKey: n];
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

