//
//  DDGetoptLong.m
//  ddcurl
//
//  Created by Dave Dribin on 6/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDGetoptLong.h"

@interface DDGetoptLong (Private)

- (struct option *) firstOption;
- (struct option *) currentOption;
- (void) addOption;

@end

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
    // Non-single char options start after as the last ASCII character
    mNextShortOption = 256;
    mOptionsData = [[NSMutableData alloc] initWithLength: sizeof(struct option)];
    mCurrentOption = 0;
    mUtf8Data = [[NSMutableArray alloc] init];
    mOptionString = [[NSMutableString alloc] init];
    mSelectorByShortOption = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void) addOptionsFromTable: (DDGetoptOption *) optionTable;
{
    DDGetoptOption * currentOption = optionTable;
    while ((currentOption->longOption != nil) ||
           (currentOption->shortOption != 0))
    {
        [self addLongOption: currentOption->longOption
                shortOption: currentOption->shortOption
                   selector: currentOption->selector
            argumentOptions: currentOption->argumentOptions];
        currentOption++;
    }
}

- (void) addLongOption: (NSString *) longOption
           shortOption: (char) shortOption
              selector: (SEL) selector
       argumentOptions: (DDGetoptArgumentOptions) argumentOptions;
{
    const char * utf8String = [longOption UTF8String];
    NSData * utf8Data = [NSData dataWithBytes: utf8String length: strlen(utf8String)];
    
    struct option * option = [self currentOption];
    option->name = utf8String;
    option->has_arg = argumentOptions;
    option->flag = NULL;

    int shortOptionValue;
    if (shortOption != 0)
    {
        shortOptionValue = shortOption;
        option->val = shortOption;
        if (argumentOptions != DDGetoptNoArgument)
            [mOptionString appendFormat: @"%c:", shortOption];
        else
            [mOptionString appendFormat: @"%c", shortOption];
    }
    else
    {
        shortOptionValue = mNextShortOption;
        mNextShortOption++;
        option->val = shortOptionValue;
    }
    [self addOption];
    
    [mSelectorByShortOption setObject: NSStringFromSelector(selector)
                               forKey: [NSNumber numberWithInt: shortOptionValue]];
    
    [mUtf8Data addObject: utf8Data];
}

- (void) addLongOption: (NSString *) longOption
              selector: (SEL) selector
       argumentOptions: (DDGetoptArgumentOptions) argumentOptions;
{
    [self addLongOption: longOption shortOption: 0
               selector: selector argumentOptions: argumentOptions];
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
    struct option * option = [self currentOption];
    option->name = NULL;
    option->has_arg = 0;
    option->flag = NULL;
    option->val = 0;
    
    const char * optionString = [mOptionString UTF8String];
    int ch;
    while ((ch = getopt_long(argc, argv, optionString, [self firstOption], NULL)) != -1)
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

@implementation DDGetoptLong (Private)

- (struct option *) firstOption;
{
    struct option * options = [mOptionsData mutableBytes];
    return options;
}

- (struct option *) currentOption;
{
    struct option * options = [mOptionsData mutableBytes];
    return &options[mCurrentOption];
}

- (void) addOption;
{
    [mOptionsData increaseLengthBy: sizeof(struct option)];
    mCurrentOption++;
}

@end

