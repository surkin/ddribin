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

@interface DDHidDevice : NSObject
{
    io_object_t mHidDevice;
	IOHIDDeviceInterface122** mDeviceInterface;

    NSMutableDictionary * mProperties;
    NSArray * mElements;
}

- (id) initWithDevice: (io_object_t) device;

+ (NSArray *) allDevices;

#pragma mark -

- (io_object_t) ioDevice;
- (IOHIDDeviceInterface122**) deviceInterface;

- (NSDictionary *) properties;

- (NSArray *) elements;

- (NSString *) productName;
- (NSString *) manufacturer;
- (NSString *) serialNumber;
- (NSString *) transport;
- (long) vendorId;
- (long) productId;
- (long) version;
- (long) usbLocationId;
- (long) usagePage;
- (long) usage;

@end
