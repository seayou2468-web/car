#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CarTool.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printf("Usage: actool <command> [args]\n");
            printf("Commands:\n");
            printf("  pack <input_xcassets_path> <output_car_path>   Pack an .xcassets folder into a .car file\n");
            printf("  unpack <input_car_path> <output_dir>          Unpack a .car file into an .xcassets structure\n");
            return 1;
        }

        NSString *cmd = [NSString stringWithUTF8String:argv[1]];
        CTPacker *packer = [[CTPacker alloc] init];
        CTUnpacker *unpacker = nil;
        NSError *error = nil;

        if ([cmd isEqualToString:@"pack"]) {
            if (argc < 4) {
                printf("Error: Missing arguments for pack command.\n");
                return 1;
            }
            NSString *input = [NSString stringWithUTF8String:argv[2]];
            NSString *output = [NSString stringWithUTF8String:argv[3]];
            printf("Packing %s into %s...\n", [input UTF8String], [output UTF8String]);
            if ([packer packXcassetsPath:input toCarPath:output error:&error]) {
                printf("Successfully packed %s.\n", [output UTF8String]);
            } else {
                printf("Failed to pack %s: %s\n", [output UTF8String], [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else if ([cmd isEqualToString:@"unpack"]) {
            if (argc < 4) {
                printf("Error: Missing arguments for unpack command.\n");
                return 1;
            }
            NSString *input = [NSString stringWithUTF8String:argv[2]];
            NSString *output = [NSString stringWithUTF8String:argv[3]];
            printf("Unpacking %s into %s...\n", [input UTF8String], [output UTF8String]);
            unpacker = [[CTUnpacker alloc] initWithCarPath:input];
            if ([unpacker unpackToPath:output error:&error]) {
                printf("Successfully unpacked %s.\n", [input UTF8String]);
            } else {
                printf("Failed to unpack %s: %s\n", [input UTF8String], [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else {
            printf("Error: Unknown command %s.\n", [cmd UTF8String]);
            return 1;
        }
    }
    return 0;
}
