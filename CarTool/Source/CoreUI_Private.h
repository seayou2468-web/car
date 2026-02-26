#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef struct _renditionkeytoken {
    uint16_t identifier;
    uint16_t value;
} renditionkeytoken;

@interface CUIRenditionKey : NSObject <NSCopying, NSCoding>
+ (instancetype)renditionKeyWithKeyList:(const renditionkeytoken *)list;
- (void)setValuesFromKeyList:(const renditionkeytoken *)list;
- (const renditionkeytoken *)keyList;
@end

@interface CSIGenerator : NSObject
- (instancetype)initWithCanvasSize:(CGSize)size count:(NSUInteger)count;
- (void)addBitmap:(id)bitmap; // Can be a CGImageRef or an object wrapping pixels
- (void)setPixelFormat:(uint32_t)format;
- (void)setScaleFactor:(double)scale;
- (void)setExifOrientation:(int)orientation;
- (void)setName:(NSString *)name;
- (void)setRenditionProperties:(NSDictionary *)props;
- (NSData *)CSIRepresentationWithValidation:(BOOL)validate;
@end

@interface CUIMutableCommonAssetStorage : NSObject
- (instancetype)initWithPath:(NSString *)path;
- (void)setRenditionKey:(const renditionkeytoken *)key forName:(NSString *)name;
- (void)setAsset:(NSData *)data forKey:(const renditionkeytoken *)key;
- (void)setStorageFlag:(uint32_t)flag;
- (void)setVersionString:(NSString *)version;
- (void)setUuid:(NSString *)uuid;
- (void)setKeyFormatData:(NSData *)data;
- (BOOL)writeToDisk;
@end

@interface CUICatalog : NSObject
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;
- (NSArray *)allAssetNames;
- (id)imageWithName:(NSString *)name scaleFactor:(double)scale;
@end
