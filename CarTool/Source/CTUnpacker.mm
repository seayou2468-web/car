#import "CTUnpacker.h"
#import "CTConstants.h"
#import "CoreUI_Private.h"
#import <UIKit/UIKit.h>

@implementation CTUnpacker {
    NSString *_path;
    CUICommonAssetStorage *_storage;
}

- (instancetype)initWithCarPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = path;
        _storage = [[NSClassFromString(@"CUICommonAssetStorage") alloc] initWithPath:path];
    }
    return self;
}

- (BOOL)unpackToPath:(NSString *)destinationPath error:(NSError **)error {
    if (!_storage) {
        if (error) *error = [NSError errorWithDomain:@"CTError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Could not open CAR file"}];
        return NO;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];

    CUICatalog *catalog = [[NSClassFromString(@"CUICatalog") alloc] initWithURL:[NSURL fileURLWithPath:_path] error:nil];
    NSArray *names = [_storage allAssetNames];

    for (NSString *name in names) {
        NSString *assetDir = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.imageset", name]];
        [fm createDirectoryAtPath:assetDir withIntermediateDirectories:YES attributes:nil error:nil];

        NSMutableArray *imageInfoList = [NSMutableArray array];

        // Check 1x, 2x, 3x for both iPhone and iPad
        NSArray *idioms = @[@"universal", @"iphone", @"ipad"];
        for (NSString *idiom in idioms) {
            for (int scale = 1; scale <= 3; scale++) {
                // In a real implementation, we would use private APIs to iterate all renditions
                // for this asset name specifically. Here we use a heuristic with CUICatalog.
                UIImage *image = [catalog imageWithName:name scaleFactor:scale];
                if (image) {
                    NSString *filename = [NSString stringWithFormat:@"%@_%@_%dx.png", name, idiom, scale];
                    NSString *imgPath = [assetDir stringByAppendingPathComponent:filename];
                    NSData *pngData = UIImagePNGRepresentation(image);
                    if (pngData) {
                        [pngData writeToFile:imgPath atomically:YES];
                        [imageInfoList addObject:@{
                            @"idiom": idiom,
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

@end
