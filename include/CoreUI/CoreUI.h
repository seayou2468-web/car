#import <Foundation/Foundation.h>

typedef struct _renditionkeytoken {
    uint16_t identifier;
    uint16_t value;
} renditionkeytoken;

typedef struct _renditionkeyfmt {
    uint32_t magic;
    uint32_t reserved;
    uint32_t num_identifiers;
    uint32_t identifiers[0];
} renditionkeyfmt;

@interface CUICommonAssetStorage : NSObject
- (instancetype)initWithPath:(NSString *)path;
- (NSArray *)allAssetNames;
- (NSData *)allRenditionKeys;
- (const renditionkeyfmt *)keyFormat;
- (NSData *)renditionWithKey:(const renditionkeytoken *)key;
@end

@interface CUIMutableCommonAssetStorage : CUICommonAssetStorage
- (instancetype)initWithPath:(NSString *)path;
- (void)setRenditionKey:(const renditionkeytoken *)key forName:(NSString *)name;
- (void)setAsset:(NSData *)data forKey:(const renditionkeytoken *)key;
- (void)setStorageFlag:(uint32_t)flag;
- (void)setVersionString:(NSString *)version;
- (void)setUuid:(NSString *)uuid;
- (BOOL)writeToDisk;
@end

@interface CUICatalog : NSObject
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;
- (NSArray *)allAssetNames;
- (id)imageWithName:(NSString *)name scaleFactor:(CGFloat)scale;
@end
