#import "HTMLFromSourceCode.h"
#import <Foundation/Foundation.h>

CFDataRef createHTMLDataFromSourceCodeFile(CFURLRef URL)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    NSURL * nsURL = (NSURL *) URL;
    NSString * path = [nsURL path];
    NSPipe * output = [NSPipe pipe];
    NSPipe * error = [NSPipe pipe];
    NSTask * enscriptTask = [[NSTask alloc] init];
#if 0
    NSArray * arguments = [NSArray arrayWithObjects: @"-E", @"--color",
                           @"-W", @"html", @"-o", @"-", path, nil];
    [enscriptTask setLaunchPath: @"/usr/bin/enscript"];
#else
    NSBundle * myBundle = [NSBundle bundleWithIdentifier: @"org.dribin.dave.QLEnscript"];
    NSString * enscriptStates = [myBundle pathForResource: @"enscript" ofType: @"st"];
    NSArray * arguments = [NSArray arrayWithObjects:
                           @"-f", enscriptStates,
                           @"-Dcolormodel=emacs", @"-Dhl_level=heavy",
                           @"-Dlanguage=html",
                           @"-Dnuminput_files=1", @"-Dtoc=0",
                           @"-Ddocument_title=foo",
                           path, nil];
    [enscriptTask setLaunchPath: @"/usr/bin/states"];
#endif
    [enscriptTask setArguments: arguments];
    [enscriptTask setStandardOutput: output];
    [enscriptTask setStandardError: error];
    
    NSFileHandle * outputFile = [output fileHandleForReading];
    NSFileHandle * errorFile = [error fileHandleForReading];
    [enscriptTask launch];
    NSData * data = [[outputFile readDataToEndOfFile] retain];
    [errorFile readDataToEndOfFile];
    [enscriptTask waitUntilExit];
    [enscriptTask release];
    
    [pool release];

    return (CFDataRef) data;
}
