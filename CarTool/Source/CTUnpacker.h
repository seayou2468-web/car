#import <Foundation/Foundation.h>

@interface CTUnpacker : NSObject

- (instancetype)initWithCarPath:(NSString *)path;
- (BOOL)unpackToPath:(NSString *)destinationPath error:(NSError **)error;

@end
