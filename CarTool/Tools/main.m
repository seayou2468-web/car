#import <Foundation/Foundation.h>
#import "CarTool.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 3) {
            printf("Usage: car-tool <unpack|pack> <input> <output>\n");
            return 1;
        }

        NSString *cmd = [NSString stringWithUTF8String:argv[1]];
        NSString *input = [NSString stringWithUTF8String:argv[2]];
        NSString *output = [NSString stringWithUTF8String:argv[3]];

        if ([cmd isEqualToString:@"unpack"]) {
            CTUnpacker *unpacker = [[CTUnpacker alloc] initWithCarPath:input];
            NSError *error;
            if ([unpacker unpackToPath:output error:&error]) {
                printf("Successfully unpacked to %s\n", [output UTF8String]);
            } else {
                printf("Error: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else if ([cmd isEqualToString:@"pack"]) {
            CTPacker *packer = [[CTPacker alloc] init];
            NSError *error;
            if ([packer packXcassetsPath:input toCarPath:output error:&error]) {
                printf("Successfully packed to %s\n", [output UTF8String]);
            } else {
                printf("Error: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}
