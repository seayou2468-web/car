#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

typedef struct _renditionkeytoken {
    uint16_t identifier;
    uint16_t value;
} renditionkeytoken;

@interface CUIRenditionKey : NSObject <NSCopying, NSCoding>
+ (instancetype)renditionKeyWithKeyList:(const renditionkeytoken *)list;
- (instancetype)initWithKeyList:(const renditionkeytoken *)list;
- (void)setValuesFromKeyList:(const renditionkeytoken *)list;
- (const renditionkeytoken *)keyList;
// Setters for all standard attributes
- (void)setThemeElement:(unsigned short)arg1;
- (void)setThemePart:(unsigned short)arg1;
- (void)setThemeSize:(unsigned short)arg1;
- (void)setThemeDirection:(unsigned short)arg1;
- (void)setThemeValue:(unsigned short)arg1;
- (void)setThemeDimension1:(unsigned short)arg1;
- (void)setThemeDimension2:(unsigned short)arg1;
- (void)setThemeState:(unsigned short)arg1;
- (void)setThemeLayer:(unsigned short)arg1;
- (void)setThemeScale:(unsigned short)arg1;
- (void)setThemePresentationState:(unsigned short)arg1;
- (void)setThemeIdiom:(unsigned short)arg1;
- (void)setThemeSubtype:(unsigned short)arg1;
- (void)setThemeIdentifier:(unsigned short)arg1;
- (void)setThemePreviousValue:(unsigned short)arg1;
- (void)setThemePreviousState:(unsigned short)arg1;
- (void)setThemeHorizontalSizeClass:(unsigned short)arg1;
- (void)setThemeVerticalSizeClass:(unsigned short)arg1;
- (void)setThemeMemoryClass:(unsigned short)arg1;
- (void)setThemeGraphicsClass:(unsigned short)arg1;
- (void)setThemeDisplayGamut:(unsigned short)arg1;
- (void)setThemeDeploymentTarget:(unsigned short)arg1;
- (void)setThemeAppearance:(unsigned short)arg1;
- (void)setThemeLocalization:(unsigned short)arg1;
@end

@interface CSIGenerator : NSObject
- (instancetype)initWithCanvasSize:(CGSize)size count:(NSUInteger)count;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithRawData:(NSData *)data pixelFormat:(uint32_t)format layout:(short)layout;
- (instancetype)initWithColorNamed:(NSString *)name colorSpaceID:(unsigned long long)cs components:(const double *)components;

- (void)addBitmap:(id)bitmap;
- (void)setPixelFormat:(uint32_t)format;
- (void)setScaleFactor:(double)scale;
- (void)setExifOrientation:(int)orientation;
- (void)setName:(NSString *)name;
- (void)setUTI:(NSString *)uti;
- (void)setCompressionType:(uint32_t)type;
- (void)setRenditionProperties:(NSDictionary *)props;
- (void)setAllowLossyCompression:(BOOL)allow;
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
- (void)setAssociatedChecksum:(uint32_t)checksum;
- (void)setColorSpaceID:(uint32_t)id;
- (void)setAppearanceIdentifier:(unsigned short)arg1 forName:(NSString *)arg2;
- (void)setLocalizationIdentifier:(unsigned short)arg1 forName:(NSString *)arg2;
- (BOOL)writeToDisk;
@end

@interface CUICatalog : NSObject
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;
- (NSArray *)allAssetNames;
- (id)imageWithName:(NSString *)name scaleFactor:(double)scale;
- (id)imageWithName:(NSString *)name scaleFactor:(double)scale deviceIdiom:(long)idiom;
- (id)colorWithName:(NSString *)name;
@end

@interface CUICommonAssetStorage : NSObject
- (instancetype)initWithPath:(NSString *)path;
- (NSArray *)allAssetNames;
- (NSData *)allRenditionKeys;
- (const renditionkeytoken *)keyFormat;
- (NSData *)renditionWithKey:(const renditionkeytoken *)key;
- (NSArray *)allRenditionKeysForName:(NSString *)name;
- (NSData *)assetForKey:(const renditionkeytoken *)key;
@end
