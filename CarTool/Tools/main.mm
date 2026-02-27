#import <Foundation/Foundation.h>
#import "CarTool.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printf("Usage: cartool <cmd> [args]\n");
            printf("  pack <xcassets_path> <output_car_path>\n");
            printf("  unpack <car_path> <output_dir>\n");
            return 1;
        }

        NSString *cmd = [NSString stringWithUTF8String:argv[1]];

        if ([cmd isEqualToString:@"pack"] && argc >= 4) {
            NSString *input = [NSString stringWithUTF8String:argv[2]];
            NSString *output = [NSString stringWithUTF8String:argv[3]];
            CTPacker *packer = [[CTPacker alloc] init];
            NSError *error;
            if ([packer packXcassetsPath:input toCarPath:output error:&error]) {
                printf("Packed successfully.\n");
            } else {
                printf("Error: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else if ([cmd isEqualToString:@"unpack"] && argc >= 4) {
            NSString *input = [NSString stringWithUTF8String:argv[2]];
            NSString *output = [NSString stringWithUTF8String:argv[3]];
            CTUnpacker *unpacker = [[CTUnpacker alloc] initWithCarPath:input];
            NSError *error;
            if ([unpacker unpackToPath:output error:&error]) {
                printf("Unpacked successfully.\n");
            } else {
                printf("Error: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}
