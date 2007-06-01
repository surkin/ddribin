//
//  DDGetoptLong.m
//  ddcurl
//
//  Created by Dave Dribin on 6/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDGetoptLong.h"

// Non-single char options start after as the last ASCII character
#define FIRST_SHORT_OPTION 256

@implementation DDGetoptLong

+ (DDGetoptLong *) optionsWithTarget: (id) target;
{
    return [[[self alloc] initWithTarget: target] autorelease];
}

- (id) initWithTarget: (id) target;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mTarget = target;
    mNextShortOption = FIRST_SHORT_OPTION;
    mOptionsData = [[NSMutableData alloc] initWithLength: sizeof(struct option)];
    mCurrentOption = 0;
    mUtf8Data = [[NSMutableArray alloc] init];
    mOptionString = [[NSMutableString alloc] init];
    mSelectorByShortOption = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void) addLongOption: (NSString *) longOption
           shortOption: (char) shortOption
              selector: (SEL) selector
       argumentOptions: (int) argumentOptions;
{
    const char * utf8String = [longOption UTF8String];
    NSData * utf8Data = [NSData dataWithBytes: utf8String length: strlen(utf8String)];
    
    struct option * options = [mOptionsData mutableBytes];
    options[mCurrentOption].name = utf8String;
    options[mCurrentOption].has_arg = argumentOptions;
    options[mCurrentOption].flag = NULL;
    options[mCurrentOption].val = shortOption;
    
    [mOptionsData increaseLengthBy: sizeof(struct option)];
    mCurrentOption++;
    
#if 0
    if (shortOption < FIRST_SHORT_OPTION)
    {
#endif
        if ((argumentOptions == required_argument) ||
            (argumentOptions == optional_argument))
        {
            [mOptionString appendFormat: @"%c:", shortOption];
        }
        else
        {
            [mOptionString appendFormat: @"%c", shortOption];
        }
#if 0
    }
#endif
    
    [mSelectorByShortOption setObject: NSStringFromSelector(selector)
                               forKey: [NSNumber numberWithInt: shortOption]];
    
    [mUtf8Data addObject: utf8Data];
}

- (void) addLongOption: (NSString *) longOption
              selector: (SEL) selector
       argumentOptions: (int) argumentOptions;
{
}

- (NSArray *) processOptions;
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSArray * arguments = [processInfo arguments];
    NSString * command = [processInfo processName];
    return [self processOptionsWithArguments: arguments command: command];
}

- (NSArray *) processOptionsWithArguments: (NSArray *) arguments
                                  command: (NSString *) command;
{
    int argc = [arguments count];
    char ** argv = alloca(sizeof(char *) * argc);
    int i;
    for (i = 0; i < argc; i++)
    {
        NSString * argument = [arguments objectAtIndex: i];
        argv[i] = (char *) [argument UTF8String];
    }
    
    // Make sure list is NULL terminated
    struct option * options = [mOptionsData mutableBytes];
    options[mCurrentOption].name = NULL;
    options[mCurrentOption].has_arg = 0;
    options[mCurrentOption].flag = NULL;
    options[mCurrentOption].val = 0;
    
    const char * optionString = [mOptionString UTF8String];
    int ch;
    while ((ch = getopt_long(argc, argv, optionString, options, NULL)) != -1)
    {
        NSString * nsoptarg = nil;
        if (optarg != NULL)
            nsoptarg = [NSString stringWithUTF8String: optarg];
        
        NSString * selectorString = [mSelectorByShortOption objectForKey: [NSNumber numberWithInt: ch]];
        if (selectorString != nil)
        {
            SEL selector = NSSelectorFromString(selectorString);
            [mTarget performSelector: selector withObject: nsoptarg];
        }
        else
        {
            fprintf(stderr, "Try `%s --help` for more information.\n", [command UTF8String]);
            return nil;
        }
    }
    
    NSRange range = NSMakeRange(optind, argc - optind);
    return [arguments subarrayWithRange: range];
}

@end
