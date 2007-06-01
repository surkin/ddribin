#import <Foundation/Foundation.h>
#import "DDCurlCliApp.h"


static int run_app(int argc, char * const * argv)
{
    DDCurlCliApp * app = nil;
    int result = 0;
    @try
    {
        app = [[DDCurlCliApp alloc] init];
        result = [app run];
    }
    @finally
    {
        if (app != nil)
        {
            [app release];
            app = nil;
        }
    }
    
    return result;
}

int main (int argc, char * const * argv)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    int result = run_app(argc, argv);

    [pool release];
    return result;
}
