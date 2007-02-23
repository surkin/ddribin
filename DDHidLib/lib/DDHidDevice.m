/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "DDHidDevice.h"
#import "DDHidUsage.h"
#import "DDHidElement.h"
#import "DDHidQueue.h"
#import "NSDictionary+DDHidExtras.h"
#import "NSXReturnThrowError.h"

@interface DDHidDevice (Private)

- (BOOL) initPropertiesWithError: (NSError **) error_;
- (BOOL) createDeviceInterfaceWithError: (NSError **) error_;

@end

@implementation DDHidDevice

- (id) initWithDevice: (io_object_t) device error: (NSError **) error_;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHidDevice = device;
    
    if (![self initPropertiesWithError: error_])
    {
        [self release];
        return nil;
    }
    
    if (![self createDeviceInterfaceWithError: error_])
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
                                      withClass: [DDHidDevice class]
                              skipZeroLocations: NO];
}

+ (NSArray *) allDevicesMatchingUsagePage: (unsigned) usagePage
                                  usageId: (unsigned) usageId
                                withClass: (Class) hidClass
                        skipZeroLocations: (BOOL) skipZeroLocations;
{
	// Set up a matching dictionary to search the I/O Registry by class
	// name for all HID class devices
	CFMutableDictionaryRef hidMatchDictionary =
    IOServiceMatching(kIOHIDDeviceKey);
    NSMutableDictionary * objcMatchDictionary =
        (NSMutableDictionary *) hidMatchDictionary;
    [objcMatchDictionary ddhid_setObject: [NSNumber numberWithUnsignedInt: usagePage]
                               forString: kIOHIDDeviceUsagePageKey];
    [objcMatchDictionary ddhid_setObject: [NSNumber numberWithUnsignedInt: usageId]
                               forString: kIOHIDDeviceUsageKey];
    return [self allDevicesMatchingCFDictionary: hidMatchDictionary
                                      withClass: hidClass
                              skipZeroLocations: skipZeroLocations];
}

+ (NSArray *) allDevicesMatchingCFDictionary: (CFDictionaryRef) matchDictionary
                                   withClass: (Class) hidClass
                           skipZeroLocations: (BOOL) skipZeroLocations;
{
	// Now search I/O Registry for matching devices.
	io_iterator_t hidObjectIterator = MACH_PORT_NULL;
    NSMutableArray * devices = [NSMutableArray array];
    @try
    {
        NSXThrowError(IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                   matchDictionary,
                                                   &hidObjectIterator));
        
        if (hidObjectIterator == 0)
            return [NSArray array];
        
        io_object_t hidDevice;
        while (hidDevice = IOIteratorNext(hidObjectIterator))
        {
            NSError * error = nil;
            DDHidDevice * device = [[hidClass alloc] initWithDevice: hidDevice
                                                              error: &error];
            if (device == nil)
            {
                NSXRaiseError(error);
            }
            [device autorelease];
            if (([device locationId] == 0) && skipZeroLocations)
                continue;
            
            [devices addObject: device];
        }
        
        // This makes sure the array return is consistent from run to run, 
        // assuming no new devices were added.
        [devices sortUsingSelector: @selector(compareByLocationId:)];
    }
    @finally
    {
        if (hidObjectIterator != MACH_PORT_NULL)
            IOObjectRelease(hidObjectIterator);
    }
    
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

- (long) getElementValue: (DDHidElement *) element;
{
    IOHIDEventStruct event;
    NSXThrowError((*mDeviceInterface)->getElementValue(mDeviceInterface,
                                                       [element cookie],
                                                       &event));
    return event.value;
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
    return [mProperties ddhid_stringForString: kIOHIDProductKey]; 
}

//=========================================================== 
// - manufacturer
//=========================================================== 
- (NSString *) manufacturer
{
    return [mProperties ddhid_stringForString: kIOHIDManufacturerKey];
}

//=========================================================== 
// - serialNumber
//=========================================================== 
- (NSString *) serialNumber
{
    return [mProperties ddhid_stringForString: kIOHIDSerialNumberKey];
}

//=========================================================== 
// - transport
//=========================================================== 
- (NSString *) transport
{
    return [mProperties ddhid_stringForString: kIOHIDTransportKey];
}

//=========================================================== 
// - vendorId
//=========================================================== 
- (long) vendorId
{
    return [mProperties ddhid_longForString: kIOHIDVendorIDKey];
}

//=========================================================== 
// - productId
//=========================================================== 
- (long) productId
{
    return [mProperties ddhid_longForString: kIOHIDProductIDKey];
}

//=========================================================== 
// - version
//=========================================================== 
- (long) version
{
    return [mProperties ddhid_longForString: kIOHIDVersionNumberKey];
}

//=========================================================== 
// - locationId
//=========================================================== 
- (long) locationId
{
    return [mProperties ddhid_longForString: kIOHIDLocationIDKey];
}

//=========================================================== 
// - usagePage
//=========================================================== 
- (long) usagePage
{
    return [mProperties ddhid_longForString: kIOHIDPrimaryUsagePageKey];
}

//=========================================================== 
// - usage
//=========================================================== 
- (long) usage
{
    return [mProperties ddhid_longForString: kIOHIDPrimaryUsageKey];
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

- (BOOL) initPropertiesWithError: (NSError **) error_;
{
    NSError * error = nil;
    BOOL result = NO;
    
    CFMutableDictionaryRef properties;
    NSXReturnError(IORegistryEntryCreateCFProperties(mHidDevice, &properties,
                                                     kCFAllocatorDefault, kNilOptions));
    if (error)
        goto done;
    
    mProperties = (NSMutableDictionary *) properties;
    NSArray * elementProperties = [mProperties ddhid_objectForString: kIOHIDElementKey];
    mElements = [DDHidElement elementsWithPropertiesArray: elementProperties];
    [mElements retain];
    
    unsigned usagePage = [mProperties ddhid_unsignedIntForString: kIOHIDPrimaryUsagePageKey];
    unsigned usageId = [mProperties ddhid_unsignedIntForString: kIOHIDPrimaryUsageKey];
    
    mPrimaryUsage = [[DDHidUsage alloc] initWithUsagePage: usagePage
                                                  usageId: usageId];
    mUsages = [[NSMutableArray alloc] init];
    
    NSArray * usagePairs = [mProperties ddhid_objectForString: kIOHIDDeviceUsagePairsKey];
    NSEnumerator * e = [usagePairs objectEnumerator];
    NSDictionary * usagePair;
    while (usagePair = [e nextObject])
    {
        usagePage = [usagePair ddhid_unsignedIntForString: kIOHIDDeviceUsagePageKey];
        usageId = [usagePair ddhid_unsignedIntForString: kIOHIDDeviceUsageKey];
        DDHidUsage * usage = [DDHidUsage usageWithUsagePage: usagePage
                                                    usageId: usageId];
        [mUsages addObject: usage];
    }
    
    mElementsByCookie = [[NSMutableDictionary alloc] init];
    [self indexElements: mElements];
    result = YES;
    
done:
        if (error_)
            *error_ = error;
    return result;
}

- (BOOL) createDeviceInterfaceWithError: (NSError **) error_;
{
	io_name_t className;
	IOCFPlugInInterface ** plugInInterface = NULL;
	SInt32 score = 0;
    NSError * error = nil;
    BOOL result = NO;
	
	mDeviceInterface = NULL;
	
	NSXReturnError(IOObjectGetClass(mHidDevice, className));
    if (error)
        goto done;
	
	NSXReturnError(IOCreatePlugInInterfaceForService(mHidDevice,
                                                     kIOHIDDeviceUserClientTypeID,
                                                     kIOCFPlugInInterfaceID,
													 &plugInInterface,
													 &score));
    if (error)
        goto done;
    
    //Call a method of the intermediate plug-in to create the device interface
    NSXReturnError((*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), (LPVOID) &mDeviceInterface));
    if (error)
        goto done;
    
    result = YES;
    
done:
        if (plugInInterface != NULL)
            (*plugInInterface)->Release(plugInInterface);
    if (error_)
        *error_ = error;
	return result;
}

@end

