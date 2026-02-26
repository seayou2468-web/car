#import "CTPacker.h"
#import "CTConstants.h"
#import "CoreUI_Private.h"
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation CTPacker

- (BOOL)packXcassetsPath:(NSString *)xcassetsPath toCarPath:(NSString *)carPath error:(NSError **)error {
    CUIMutableCommonAssetStorage *storage = [[NSClassFromString(@"CUIMutableCommonAssetStorage") alloc] initWithPath:carPath];
    if (!storage) {
        if (error) *error = [NSError errorWithDomain:@"CTError" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Could not create CAR storage"}];
        return NO;
    }

    [storage setVersionString:@"CarTool 3.0 (Pro)"];
    [storage setStorageFlag:1];

    // Comprehensive Key Format
    uint32_t keyList[] = {7, 13, 12, 15, 16, 9, 8, 17, 1, 2, 10, 21, 23};
    NSMutableData *kfData = [NSMutableData dataWithBytes:"tmfk" length:4];
    uint32_t nkeys = sizeof(keyList) / sizeof(uint32_t);
    uint32_t klen = 12 + (nkeys * 4);
    [kfData appendBytes:&klen length:4];
    [kfData appendBytes:&nkeys length:4];
    [kfData appendBytes:keyList length:sizeof(keyList)];
    [storage setKeyFormatData:kfData];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:xcassetsPath];
    NSString *file;
    while ((file = [enumerator nextObject])) {
        NSString *fullPath = [xcassetsPath stringByAppendingPathComponent:file];
        if ([file hasSuffix:@".imageset"] || [file hasSuffix:@".appiconset"]) {
            [self processAssetSet:fullPath name:[file lastPathComponent] storage:storage];
            [enumerator skipDescendants];
        } else if ([file hasSuffix:@".colorset"]) {
            [self processColorSet:fullPath name:[file lastPathComponent] storage:storage];
            [enumerator skipDescendants];
        }
    }

    return [storage writeToDisk];
}

- (void)processAssetSet:(NSString *)path name:(NSString *)name storage:(CUIMutableCommonAssetStorage *)storage {
    NSString *jsonPath = [path stringByAppendingPathComponent:@"Contents.json"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:0 error:nil];
    NSString *assetName = [name stringByDeletingPathExtension];

    for (NSDictionary *imgInfo in json[@"images"]) {
        NSString *filename = imgInfo[@"filename"];
        if (!filename) continue;

        NSData *imgData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:filename]];
        CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)imgData, NULL);
        CGImageRef image = CGImageSourceCreateImageAtIndex(src, 0, NULL);
        if (!image) { CFRelease(src); continue; }

        CSIGenerator *generator = [[NSClassFromString(@"CSIGenerator") alloc] initWithCanvasSize:CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image)) count:1];
        [generator addBitmap:(__bridge id)image];
        [generator setName:assetName];

        double scale = [[imgInfo[@"scale"] stringByReplacingOccurrencesOfString:@"x" withString:@""] doubleValue];
        [generator setScaleFactor:scale];
        [generator setPixelFormat:'BGRA'];

        renditionkeytoken key[15];
        memset(key, 0, sizeof(key));
        int k = 0;
        key[k++] = (renditionkeytoken){CTAttributeIdiom, [self idiomForString:imgInfo[@"idiom"]]};
        key[k++] = (renditionkeytoken){CTAttributeScale, (uint16_t)scale};
        key[k++] = (renditionkeytoken){CTAttributeElement, 1};
        key[k++] = (renditionkeytoken){CTAttributePart, 1};

        if ([imgInfo[@"display-gamut"] isEqualToString:@"p3"]) {
            [generator setRenditionProperties:@{@"kCUIDisplayGamut": @1}];
            key[k++] = (renditionkeytoken){CTAttributeDisplayGamut, 1};
        }

        key[k++] = (renditionkeytoken){0, 0};

        [storage setAsset:[generator CSIRepresentationWithValidation:NO] forKey:key];
        [storage setRenditionKey:key forName:assetName];

        CGImageRelease(image);
        CFRelease(src);
    }
}

- (void)processColorSet:(NSString *)path name:(NSString *)name storage:(CUIMutableCommonAssetStorage *)storage {
    // Basic color set support (placeholder)
    NSLog(@"Processing color set: %@", name);
}

- (uint16_t)idiomForString:(NSString *)idiom {
    if ([idiom isEqualToString:@"iphone"]) return 1;
    if ([idiom isEqualToString:@"ipad"]) return 2;
    if ([idiom isEqualToString:@"watch"]) return 3;
    if ([idiom isEqualToString:@"tv"]) return 5;
    if ([idiom isEqualToString:@"mac"]) return 4;
    return 0;
}

@end
