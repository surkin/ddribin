#import <Foundation/Foundation.h>
#import "NSUrlCliApp.h"
#include <getopt.h>

enum
{
    UsernameOption = 'u',
    PasswordOption = 'p',
    HeaderOption = 'H',
    HelpOption = 'h',
    
    LastCharOption = 255,
};

static void usage(FILE * stream)
{
    fprintf(stream, "Usage: nsurl [OPTIONS] <url>\n");
}

static void print_help(void)
{
    usage(stdout);
    printf("\n");
    printf("  -u, --username=USERNAME       use USERNAME for authentication\n");
    printf("  -p, --password=PASSWORD       use PASSWORD for authentication\n");
    printf("  -H, --header=HEADER           set HTTP header\n");
    printf("  -h, --help                    display this help and exit\n");
    printf("\n");
}

static int run_app(int argc, char * const * argv)
{
    NSUrlCliApp * app = nil;
    int result = 0;
    
    @try
    {
        app = [[NSUrlCliApp alloc] init];

        /* options descriptor */
        static struct option longopts[] = {
            { "username",   required_argument,      NULL,           UsernameOption },
            { "password",   required_argument,      NULL,           PasswordOption },
            { "header",     required_argument,      NULL,           HeaderOption },
            { "help",       no_argument,            NULL,           HelpOption },
            { NULL,         0,                      NULL,           0 }
        };
        
        int ch;
        while ((ch = getopt_long(argc, argv, "u:p:H:h", longopts, NULL)) != -1)
        {
            NSString * nsoptarg = nil;
            if (optarg != NULL)
                nsoptarg = [NSString stringWithUTF8String: optarg];
            switch (ch) {
                case UsernameOption:
                    [app setUsername: nsoptarg];
                    break;
                    
                case PasswordOption:
                    [app setPassword: nsoptarg];
                    break;
                    
                case HeaderOption:
                    [app setHeaderValue: nsoptarg];
                    break;
                    
                case HelpOption:
                    print_help();
                    return 0;
                    break;
                    
                default:
                    usage(stderr);
                    return 1;
            }
        }
        argc -= optind;
        argv += optind;
        
        if (argc != 1)
        {
            usage(stderr);
            return 1;
        }
        
        [app setUrl: [NSString stringWithCString: argv[0] encoding: NSUTF8StringEncoding]];
        result = [app run] ? 0 : 1;
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