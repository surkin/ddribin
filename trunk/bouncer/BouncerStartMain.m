#import <Foundation/Foundation.h>
#include <notify.h>
#import "BouncerConstants.h"

int main(int argc, char * argv[])
{
    int result = EXIT_SUCCESS;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    notify_post(BouncerRemoteStartNotification);
    
    [pool release];
    return result;
}