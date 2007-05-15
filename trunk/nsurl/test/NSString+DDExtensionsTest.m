//
//  NSString+DDExtensionsTest.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSString+DDExtensionsTest.h"
#import "DDExtensions.h"

@implementation NSString_DDExtensionsTest

- (void) testMimeTypeForExtensionFunction;
{
    STAssertEqualObjects(DDMimeTypeForExtension(@"png"), @"image/png", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@"zip"), @"application/zip", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@"txt"), @"text/plain", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@".unknown"), @"application/octet-stream", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@""), @"application/octet-stream", nil);
}

- (void) testMimeTypeForPathCategory;
{
    STAssertEqualObjects([@"foo.png" dd_mimeTypeOfPath], @"image/png", nil);
    STAssertEqualObjects([@"foo.zip" dd_mimeTypeOfPath], @"application/zip", nil);
    STAssertEqualObjects([@"foo.txt" dd_mimeTypeOfPath], @"text/plain", nil);
    STAssertEqualObjects([@"foo.unknown" dd_mimeTypeOfPath], @"application/octet-stream", nil);
    STAssertEqualObjects([@"foo" dd_mimeTypeOfPath], @"application/octet-stream", nil);
}

@end
