#import "CTUnpacker.h"
#import "CTConstants.h"

// Private CoreUI headers
@interface CUICommonAssetStorage : NSObject
- (instancetype)initWithPath:(NSString *)path;
- (NSArray *)allAssetNames;
- (NSData *)allRenditionKeys;
- (NSData *)renditionWithKey:(NSData *)key;
@end

@interface CUICatalog : NSObject
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;
- (NSArray *)allAssetNames;
- (id)imageWithName:(NSString *)name scaleFactor:(double)scale;
@end

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

    NSArray *names = [_storage allAssetNames];
    for (NSString *name in names) {
        // Create directory for asset
        NSString *assetDir = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.imageset", name]];
        [fm createDirectoryAtPath:assetDir withIntermediateDirectories:YES attributes:nil error:nil];

        // This is a simplified extraction. In a real tool, we'd iterate through renditions.
        // For now, let's just log.
        NSLog(@"Unpacking asset: %@", name);
    }

    return YES;
}

@end
