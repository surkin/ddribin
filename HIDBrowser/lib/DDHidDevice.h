//
//  DDHidDevice.h
//  HIDBrowser
//
//  Created by Dave Dribin on 1/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDKeys.h>

@class DDHidUsage;
@class DDHidElement;
@class DDHidQueue;

@interface DDHidDevice : NSObject
{
    io_object_t mHidDevice;
	IOHIDDeviceInterface122** mDeviceInterface;

    NSMutableDictionary * mProperties;
    DDHidUsage * mPrimaryUsage;
    NSMutableArray * mUsages;
    NSArray * mElements;
    NSMutableDictionary * mElementsByCookie;
}

- (id) initWithDevice: (io_object_t) device;

#pragma mark -
#pragma mark Finding Devices

+ (NSArray *) allDevices;

+ (NSArray *) allDevicesMatchingUsagePage: (unsigned) usagePage
                                  usageId: (unsigned) usageId
                                withClass: (Class) hidClass;

+ (NSArray *) allDevicesMatchingCFDictionary: (CFDictionaryRef) matchDictionary
                                   withClass: (Class) hidClass;

#pragma mark -
#pragma mark I/O Kit Objects

- (io_object_t) ioDevice;
- (IOHIDDeviceInterface122**) deviceInterface;

#pragma mark -
#pragma mark Operations

- (void) open;
- (void) openWithOptions: (UInt32) options;
- (void) close;
- (DDHidQueue *) createQueueWithSize: (unsigned) size;

#pragma mark -
#pragma mark Properties

- (NSDictionary *) properties;

- (NSArray *) elements;
- (DDHidElement *) elementForCookie: (IOHIDElementCookie) cookie;

- (NSString *) productName;
- (NSString *) manufacturer;
- (NSString *) serialNumber;
- (NSString *) transport;
- (long) vendorId;
- (long) productId;
- (long) version;
- (long) locationId;
- (long) usagePage;
- (long) usage;
- (DDHidUsage *) primaryUsage;
- (NSArray *) usages;

- (NSComparisonResult) compareByLocationId: (DDHidDevice *) device;

@end