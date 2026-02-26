#import "CTPacker.h"
#import "CTConstants.h"

@interface CUIMutableCommonAssetStorage : NSObject
- (instancetype)initWithPath:(NSString *)path;
- (void)setRenditionKey:(const void *)key forName:(NSString *)name;
- (void)setAsset:(NSData *)data forKey:(const void *)key;
- (void)setStorageFlag:(uint32_t)flag;
- (void)setVersionString:(NSString *)version;
- (void)setUuid:(NSString *)uuid;
- (void)setKeyFormatData:(NSData *)data;
- (BOOL)writeToDisk;
@end

@implementation CTPacker

- (BOOL)packXcassetsPath:(NSString *)xcassetsPath toCarPath:(NSString *)carPath error:(NSError **)error {
    CUIMutableCommonAssetStorage *storage = [[NSClassFromString(@"CUIMutableCommonAssetStorage") alloc] initWithPath:carPath];
    if (!storage) {
        if (error) *error = [NSError errorWithDomain:@"CTError" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Could not create CAR storage"}];
        return NO;
    }

    [storage setVersionString:@"CarTool 1.0"];
    [storage setStorageFlag:1];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:xcassetsPath];
    NSString *file;
    while ((file = [enumerator nextObject])) {
        if ([file hasSuffix:@".imageset"]) {
            NSString *setName = [file stringByDeletingPathExtension];
            NSString *fullPath = [xcassetsPath stringByAppendingPathComponent:file];
            [self processImageSet:fullPath name:[setName lastPathComponent] storage:storage];
        }
    }

    return [storage writeToDisk];
}

- (void)processImageSet:(NSString *)path name:(NSString *)name storage:(CUIMutableCommonAssetStorage *)storage {
    NSString *jsonPath = [path stringByAppendingPathComponent:@"Contents.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    if (!jsonData) return;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *images = json[@"images"];

    for (NSDictionary *imgInfo in images) {
        NSString *filename = imgInfo[@"filename"];
        if (!filename) continue;

        NSString *imgPath = [path stringByAppendingPathComponent:filename];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        if (!imgData) continue;

        // Construct rendition key
        // Format: (id, value) tokens, terminated by (0, 0)
        // Here we use a simplified key for illustration.
        // Real keys depend on the KEYFORMAT block.
        struct {
            uint16_t identifier;
            uint16_t value;
        } key[10];
        memset(key, 0, sizeof(key));

        int i = 0;
        // Idiom
        key[i].identifier = CTAttributeIdiom;
        NSString *idiom = imgInfo[@"idiom"];
        if ([idiom isEqualToString:@"iphone"]) key[i].value = 1;
        else if ([idiom isEqualToString:@"ipad"]) key[i].value = 2;
        i++;

        // Scale
        key[i].identifier = CTAttributeScale;
        NSString *scale = imgInfo[@"scale"];
        key[i].value = [scale intValue];
        i++;

        // Element (Asset Name hash or ID)
        key[i].identifier = CTAttributeElement;
        key[i].value = 1; // Simplified
        i++;

        // In a real implementation, we would use CoreUI to properly
        // encode the image into a CSIR rendition.
        // For now, we add the raw data as a placeholder.
        [storage setAsset:imgData forKey:key];
        [storage setRenditionKey:key forName:name];
    }
}

@end
