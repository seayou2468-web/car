#import "CTUnpacker.h"
#import "CTConstants.h"
#import "CTAttributeMapping.h"
#import "CoreUI_Private.h"
#import <UIKit/UIKit.h>

@implementation CTUnpacker {
    NSString *_path;
}

- (instancetype)initWithCarPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

- (BOOL)unpackToPath:(NSString *)destinationPath error:(NSError **)error {
    CUICommonAssetStorage *storage = [[NSClassFromString(@"CUICommonAssetStorage") alloc] initWithPath:_path];
    if (!storage) {
        if (error) *error = [NSError errorWithDomain:@"CTError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Could not open CAR file"}];
        return NO;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];

    CUICatalog *catalog = [[NSClassFromString(@"CUICatalog") alloc] initWithURL:[NSURL fileURLWithPath:_path] error:nil];
    NSArray *names = [storage allAssetNames];

    for (NSString *name in names) {
        NSString *assetDir = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.imageset", name]];
        [fm createDirectoryAtPath:assetDir withIntermediateDirectories:YES attributes:nil error:nil];

        NSMutableArray *imageInfoList = [NSMutableArray array];

        // Forensically iterate through all keys for this specific name
        NSArray *renditionKeys = [storage allRenditionKeysForName:name];
        for (NSData *keyData in renditionKeys) {
            const renditionkeytoken *tokens = (const renditionkeytoken *)[keyData bytes];
            CUIRenditionKey *key = [[NSClassFromString(@"CUIRenditionKey") alloc] initWithKeyList:tokens];

            // Extract attributes
            long idiom = 0;
            double scale = 1.0;
            // Using reflection to call private setters/getters if needed,
            // but we can also just parse the tokens.

            for (int i = 0; tokens[i].identifier != 0; i++) {
                if (tokens[i].identifier == CTAttributeIdiom) idiom = tokens[i].value;
                if (tokens[i].identifier == CTAttributeScale) scale = tokens[i].value;
            }

            UIImage *image = nil;
            if ([catalog respondsToSelector:@selector(imageWithName:scaleFactor:deviceIdiom:)]) {
                image = [catalog imageWithName:name scaleFactor:scale deviceIdiom:idiom];
            } else {
                image = [catalog imageWithName:name scaleFactor:scale];
            }

            if (image) {
                NSString *idiomStr = [self stringForIdiom:idiom];
                NSString *filename = [NSString stringWithFormat:@"%@_%@_%dx.png", name, idiomStr, (int)scale];
                NSString *imgPath = [assetDir stringByAppendingPathComponent:filename];
                NSData *pngData = UIImagePNGRepresentation(image);
                if (pngData) {
                    [pngData writeToFile:imgPath atomically:YES];
                    [imageInfoList addObject:@{
                        @"idiom": idiomStr,
                        @"scale": [NSString stringWithFormat:@"%dx", (int)scale],
                        @"filename": filename
                    }];
                }
            }
        }

        NSDictionary *contents = @{
            @"images": imageInfoList,
            @"info": @{@"version": @1, @"author": @"CarTool Singularity"}
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contents options:NSJSONWritingPrettyPrinted error:nil];
        [jsonData writeToFile:[assetDir stringByAppendingPathComponent:@"Contents.json"] atomically:YES];
    }

    return YES;
}

- (NSString *)stringForIdiom:(long)idiom {
    switch (idiom) {
        case 1: return @"iphone";
        case 2: return @"ipad";
        case 3: return @"watch";
        case 4: return @"mac";
        case 5: return @"tv";
        default: return @"universal";
    }
}

@end
