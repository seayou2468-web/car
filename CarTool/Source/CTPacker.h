#import <Foundation/Foundation.h>

@interface CTPacker : NSObject

- (BOOL)packXcassetsPath:(NSString *)xcassetsPath toCarPath:(NSString *)carPath error:(NSError **)error;

@end
