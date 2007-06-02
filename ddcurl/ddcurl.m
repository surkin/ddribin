#import <Foundation/Foundation.h>
#import "DDCurlCliApp.h"
#import "DDCliApplication.h"

int main (int argc, char * const * argv)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int result = DDCliAppRunWithClass([DDCurlCliApp class]);
    [pool release];
    return result;
}
