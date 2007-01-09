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
    NSMutableDictionary * mProperties;

    NSString * mProductName;
    NSString * mManufacturer;
    NSString * mSerialNumber;
    NSString * mTransport;
    long mVendorId;
    long mProductId;
    long mVersion;
    long mUsbLocationId;
    long mUsagePage;
    long mUsage;
}

- (id) initWithDevice: (io_object_t) device;

+ (NSArray *) allDevices;

#pragma mark -

- (NSDictionary *) properties;

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
