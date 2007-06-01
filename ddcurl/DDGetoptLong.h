//
//  DDGetoptLong.h
//  ddcurl
//
//  Created by Dave Dribin on 6/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <getopt.h>
#import <libgen.h>

enum
{
    DDGetoptNoArgument = no_argument,
    DDGetoptOptionalArgument = optional_argument,
    DDGetoptRequiredArgument = required_argument,
};

@interface DDGetoptLong : NSObject
{
    id mTarget;
    int mNextShortOption;
    NSMutableString * mOptionString;
    NSMutableDictionary * mSelectorByShortOption;
    NSMutableData * mOptionsData;
    int mCurrentOption;
    NSMutableArray * mUtf8Data;
}

+ (DDGetoptLong *) optionsWithTarget: (id) target;

- (id) initWithTarget: (id) target;

- (void) addLongOption: (NSString *) longOption
           shortOption: (char) shortOption
              selector: (SEL) selector
       argumentOptions: (int) argumentOptions;

- (void) addLongOption: (NSString *) longOption
              selector: (SEL) selector
       argumentOptions: (int) argumentOptions;

- (NSArray *) processOptions;

- (NSArray *) processOptionsWithArguments: (NSArray *) arguments
                                  command: (NSString *) command;

@end
