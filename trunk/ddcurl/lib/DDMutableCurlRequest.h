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

#import <Cocoa/Cocoa.h>

@class DDCurlMultipartForm;

@interface DDMutableCurlRequest : NSObject
{
    NSURL * mUrl;
    DDCurlMultipartForm * mMultipartForm;
    NSString * mUsername;
    NSString * mPassword;
    NSString * mHTTPMethod;
    NSMutableDictionary * mHeaders;
    BOOL mAllowRedirects;
}

#pragma mark -
#pragma mark Class Constructors

+ (DDMutableCurlRequest *) request;

+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;

+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Constructors

- (id) init;

- (id) initWithURL: (NSURL *) url;

- (id) initWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Properties

- (NSURL *) URL;
- (void) setURL: (NSURL *) theURL;

- (void) setURLString: (NSString *) urlString;

- (NSString *) urlString;

- (NSString *) username;
- (void) setUsername: (NSString *) theUsername;

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

- (BOOL) allowRedirects;
- (void) setAllowRedirects: (BOOL) flag;

- (DDCurlMultipartForm *) multipartForm;
- (void) setMultipartForm: (DDCurlMultipartForm *) theMultipartForm;

- (NSString *) HTTPMethod;
- (void) setHTTPMethod: (NSString *) theHTTPMethod;

- (void) setValue: (NSString *) value forHTTPHeaderField: (NSString *) field;

- (NSDictionary *) allHeaders;

@end
