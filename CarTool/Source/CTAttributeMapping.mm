#import "CTAttributeMapping.h"

@implementation CTAttributeMapping

+ (NSDictionary *)mappingFromJSON {
    return @{
        @"idiom": @(CTAttributeIdiom),
        @"scale": @(CTAttributeScale),
        @"display-gamut": @(CTAttributeDisplayGamut),
        @"appearance": @(CTAttributeAppearance),
        @"horizontal-size-class": @(CTAttributeHorizontalSizeClass),
        @"vertical-size-class": @(CTAttributeVerticalSizeClass),
        @"memory": @(CTAttributeMemoryClass),
        @"graphics-feature-set": @(CTAttributeGraphicsClass),
        @"subtype": @(CTAttributeSubtype),
        @"localization": @(CTAttributeLocalization),
        @"glyph-weight": @(CTAttributeGlyphWeight),
        @"glyph-size": @(CTAttributeGlyphSize)
    };
}

+ (uint16_t)valueForIdiomString:(NSString *)string {
    if ([string isEqualToString:@"iphone"]) return CTIdiomIPhone;
    if ([string isEqualToString:@"ipad"]) return CTIdiomIPad;
    if ([string isEqualToString:@"watch"]) return CTIdiomWatch;
    if ([string isEqualToString:@"tv"]) return CTIdiomTV;
    return CTIdiomUniversal;
}

+ (uint16_t)valueForSizeClassString:(NSString *)string {
    if ([string isEqualToString:@"compact"]) return CTSizeClassCompact;
    if ([string isEqualToString:@"regular"]) return CTSizeClassRegular;
    return CTSizeClassAny;
}

@end
