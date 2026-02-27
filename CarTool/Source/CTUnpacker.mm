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
        NSMutableArray *imageInfoList = [NSMutableArray array];
        NSMutableArray *colorInfoList = [NSMutableArray array];
        NSMutableArray *dataInfoList = [NSMutableArray array];

        NSArray *renditionKeys = [storage allRenditionKeysForName:name];
        for (NSData *keyData in renditionKeys) {
            const renditionkeytoken *tokens = (const renditionkeytoken *)[keyData bytes];

            long idiom = 0;
            double scale = 1.0;
            uint16_t appearance = 0;
            uint16_t gamut = 0;

            for (int i = 0; tokens[i].identifier != 0; i++) {
                if (tokens[i].identifier == CTAttributeIdiom) idiom = tokens[i].value;
                if (tokens[i].identifier == CTAttributeScale) scale = tokens[i].value;
                if (tokens[i].identifier == CTAttributeAppearance) appearance = tokens[i].value;
                if (tokens[i].identifier == CTAttributeDisplayGamut) gamut = tokens[i].value;
            }

            NSString *idiomStr = [self stringForIdiom:idiom];
            NSString *appearanceStr = (appearance == 1) ? @"dark" : nil;
            NSString *gamutStr = (gamut == 1) ? @"p3" : nil;

            // 1. Try Image
            UIImage *image = nil;
            if ([catalog respondsToSelector:@selector(imageWithName:scaleFactor:deviceIdiom:)]) {
                image = [catalog imageWithName:name scaleFactor:scale deviceIdiom:idiom];
            } else {
                image = [catalog imageWithName:name scaleFactor:scale];
            }

            if (image) {
                NSString *assetDir = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.imageset", name]];
                [fm createDirectoryAtPath:assetDir withIntermediateDirectories:YES attributes:nil error:nil];

                NSString *filename = [NSString stringWithFormat:@"%@_%@_%dx.png", name, idiomStr, (int)scale];
                if (appearanceStr) filename = [NSString stringWithFormat:@"%@_%@_%@_%dx.png", name, idiomStr, appearanceStr, (int)scale];

                NSString *imgPath = [assetDir stringByAppendingPathComponent:filename];
                NSData *pngData = UIImagePNGRepresentation(image);
                if (pngData) {
                    [pngData writeToFile:imgPath atomically:YES];
                    NSMutableDictionary *imgDict = [@{
                        @"idiom": idiomStr,
                        @"scale": [NSString stringWithFormat:@"%dx", (int)scale],
                        @"filename": filename
                    } mutableCopy];
                    if (appearanceStr) imgDict[@"appearance"] = appearanceStr;
                    if (gamutStr) imgDict[@"display-gamut"] = gamutStr;

                    // Handle Slicing (iOS Native)
                    if (image.capInsets.top > 0 || image.capInsets.left > 0 || image.capInsets.bottom > 0 || image.capInsets.right > 0) {
                        imgDict[@"resizing"] = @{
                            @"mode": @"9-part",
                            @"cap-insets": @{
                                @"top": @(image.capInsets.top),
                                @"left": @(image.capInsets.left),
                                @"bottom": @(image.capInsets.bottom),
                                @"right": @(image.capInsets.right)
                            }
                        };
                    }
                    [imageInfoList addObject:imgDict];
                }
                continue;
            }

            // 2. Try Color
            if ([catalog respondsToSelector:@selector(colorWithName:)]) {
                UIColor *color = [catalog colorWithName:name];
                if (color) {
                    CGFloat r, g, b, a;
                    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
                        NSMutableDictionary *colorDict = [@{
                            @"idiom": idiomStr,
                            @"color": @{
                                @"components": @{
                                    @"red": @(r),
                                    @"green": @(g),
                                    @"blue": @(b),
                                    @"alpha": @(a)
                                },
                                @"color-space": @"srgb"
                            }
                        } mutableCopy];
                        if (appearanceStr) colorDict[@"appearance"] = appearanceStr;
                        [colorInfoList addObject:colorDict];
                    }
                    continue;
                }
            }

            // 3. Try Data
            NSData *dataAsset = [storage assetForKey:tokens];
            if (dataAsset) {
                NSString *assetDir = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dataset", name]];
                [fm createDirectoryAtPath:assetDir withIntermediateDirectories:YES attributes:nil error:nil];
                NSString *filename = [NSString stringWithFormat:@"%@_%@.data", name, idiomStr];
                [dataAsset writeToFile:[assetDir stringByAppendingPathComponent:filename] atomically:YES];
                [dataInfoList addObject:@{@"idiom": idiomStr, @"filename": filename}];
            }
        }

        if (imageInfoList.count > 0) {
            [self writeContentsJson:@{@"images": imageInfoList} toDir:[destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.imageset", name]]];
        }
        if (colorInfoList.count > 0) {
            [self writeContentsJson:@{@"colors": colorInfoList} toDir:[destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.colorset", name]]];
        }
        if (dataInfoList.count > 0) {
            [self writeContentsJson:@{@"data": dataInfoList} toDir:[destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dataset", name]]];
        }
    }

    return YES;
}

- (void)writeContentsJson:(NSDictionary *)dict toDir:(NSString *)dir {
    NSMutableDictionary *contents = [dict mutableCopy];
    contents[@"info"] = @{@"version": @1, @"author": @"CarTool iOS Reconstructed"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contents options:NSJSONWritingPrettyPrinted error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    [jsonData writeToFile:[dir stringByAppendingPathComponent:@"Contents.json"] atomically:YES];
}

- (NSString *)stringForIdiom:(long)idiom {
    switch (idiom) {
        case 1: return @"iphone";
        case 2: return @"ipad";
        case 3: return @"watch";
        case 5: return @"tv";
        default: return @"universal";
    }
}

@end
