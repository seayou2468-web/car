#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CarTool.h"

void printUsage() {
    printf("iOS Native Asset Catalog Tool (Reconstructed)\n");
    printf("Usage: actool [options] <command> [args]\n");
    printf("\nCommands:\n");
    printf("  pack <input_xcassets_path> <output_car_path>   Pack an .xcassets folder into a .car file\n");
    printf("  unpack <input_car_path> <output_dir>          Unpack a .car file into an .xcassets structure\n");
    printf("\nOptions:\n");
    printf("  --platform <name>             Specify target platform (ios, watchos, tvos)\n");
    printf("  --minimum-deployment-target   Set minimum OS version (ignored in this version)\n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printUsage();
            return 1;
        }

        NSMutableArray *args = [NSMutableArray array];
        for (int i = 1; i < argc; i++) {
            [args addObject:[NSString stringWithUTF8String:argv[i]]];
        }

        NSString *cmd = nil;
        NSString *input = nil;
        NSString *output = nil;

        for (NSUInteger i = 0; i < args.count; i++) {
            NSString *arg = args[i];
            if ([arg hasPrefix:@"--"]) {
                if ([arg isEqualToString:@"--platform"]) i++; // skip next
                continue;
            }
            if (!cmd) {
                cmd = arg;
            } else if (!input) {
                input = arg;
            } else if (!output) {
                output = arg;
            }
        }

        if (!cmd || !input || !output) {
            printUsage();
            return 1;
        }

        NSError *error = nil;
        if ([cmd isEqualToString:@"pack"]) {
            CTPacker *packer = [[CTPacker alloc] init];
            printf("[*] Packing Asset Catalog: %s\n", [input UTF8String]);
            if ([packer packXcassetsPath:input toCarPath:output error:&error]) {
                printf("[+] Successfully compiled assets to %s\n", [output UTF8String]);
            } else {
                printf("[-] Error: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else if ([cmd isEqualToString:@"unpack"]) {
            CTUnpacker *unpacker = [[CTUnpacker alloc] initWithCarPath:input];
            printf("[*] Extracting Assets from: %s\n", [input UTF8String]);
            if ([unpacker unpackToPath:output error:&error]) {
                printf("[+] Successfully extracted assets to %s\n", [output UTF8String]);
            } else {
                printf("[-] Error: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else {
            printf("[-] Unknown command: %s\n", [cmd UTF8String]);
            return 1;
        }
    }
    return 0;
}
