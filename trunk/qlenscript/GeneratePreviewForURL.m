#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    NSURL * nsURL = (NSURL *) url;
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
    NSData * data = [outputFile readDataToEndOfFile];
    [errorFile readDataToEndOfFile];
    [enscriptTask waitUntilExit];
    [enscriptTask release];
    
    QLPreviewRequestSetDataRepresentation(preview, (CFDataRef) data,
                                          kUTTypeHTML,
                                          (CFDictionaryRef) [NSDictionary dictionary]);
    
    [pool release];
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
