#import <Foundation/Foundation.h>
#import "CTConstants.h"

@interface CTAttributeMapping : NSObject
+ (NSDictionary *)mappingFromJSON;
+ (uint16_t)valueForIdiomString:(NSString *)string;
+ (uint16_t)valueForSizeClassString:(NSString *)string;
@end
