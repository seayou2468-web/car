#import "CTUnpacker.h"
#import "CTConstants.h"
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

        // We iterate through renditions to find all versions of this asset
        // For simplicity in this replacement tool, we check common combinations
        for (long idiom = 0; idiom <= 5; idiom++) {
            for (int scale = 1; scale <= 3; scale++) {
                UIImage *image = nil;
                if ([catalog respondsToSelector:@selector(imageWithName:scaleFactor:deviceIdiom:)]) {
                    image = [catalog imageWithName:name scaleFactor:scale deviceIdiom:idiom];
                } else {
                    image = [catalog imageWithName:name scaleFactor:scale];
                }

                if (image) {
                    NSString *idiomStr = [self stringForIdiom:idiom];
                    NSString *filename = [NSString stringWithFormat:@"%@_%@_%dx.png", name, idiomStr, scale];
                    NSString *imgPath = [assetDir stringByAppendingPathComponent:filename];
                    NSData *pngData = UIImagePNGRepresentation(image);
                    if (pngData) {
                        [pngData writeToFile:imgPath atomically:YES];
                        [imageInfoList addObject:@{
                            @"idiom": idiomStr,
                            @"scale": [NSString stringWithFormat:@"%dx", scale],
                            @"filename": filename
                        }];
                    }
                }
            }
        }

        NSDictionary *contents = @{
            @"images": imageInfoList,
            @"info": @{@"version": @1, @"author": @"CarTool"}
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
