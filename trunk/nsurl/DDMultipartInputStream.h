//
//  DDMultipartInputStream.h
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDMultipartInputStream : NSInputStream
{
    NSString * mBoundary;
    NSInputStream * mBodyStream;
    NSMutableArray * mParts;
}

- (NSString *) boundary;

- (void) addPartWithName: (NSString *) name data: (NSData *) data;

- (void) addPartWithName: (NSString *) name string: (NSString *) string;

- (void) addPartWithName: (NSString *) name intValue: (int) intValue;

- (void) addPartWithName: (NSString *) name fileAtPath: (NSString *) path;

@end

@interface DDMultipartDataPart : NSObject
{
    NSString * mHeaders;
    NSData * mContentData;
}

+ partWithName: (NSString *) name dataContent: (NSData *) data;

+ partWithName: (NSString *) name fileContent: (NSString *) path;

- (id) initWithName: (NSString *) name dataContent: (NSData *) data;

- (id) initWithName: (NSString *) name fileContent: (NSString *) path;

- (id) initWithHeaders: (NSString *) headers dataContent: (NSData *) data;

- (NSString *) headersAsString;

- (NSData *) contentAsData;

@end