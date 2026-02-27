#ifndef CTConstants_h
#define CTConstants_h

#import <Foundation/Foundation.h>

typedef enum : uint16_t {
    CTAttributeElement = 1,
    CTAttributePart = 2,
    CTAttributeSize = 3,
    CTAttributeDirection = 4,
    CTAttributeValue = 5,
    CTAttributeDimension1 = 6,
    CTAttributeDimension2 = 7,
    CTAttributeState = 8,
    CTAttributeLayer = 9,
    CTAttributeScale = 10,
    CTAttributePresentationState = 11,
    CTAttributeIdiom = 12,
    CTAttributeSubtype = 13,
    CTAttributeIdentifier = 14,
    CTAttributePreviousValue = 15,
    CTAttributePreviousState = 16,
    CTAttributeHorizontalSizeClass = 17,
    CTAttributeVerticalSizeClass = 18,
    CTAttributeMemoryClass = 19,
    CTAttributeGraphicsClass = 20,
    CTAttributeDisplayGamut = 21,
    CTAttributeDeploymentTarget = 22,
    CTAttributeAppearance = 23,
    CTAttributeLocalization = 24,
    CTAttributeGlyphWeight = 25,
    CTAttributeGlyphSize = 26,
    CTAttributeDeploymentTarget2 = 27
} CTAttribute;

typedef enum : long {
    CTIdiomUniversal = 0,
    CTIdiomIPhone = 1,
    CTIdiomIPad = 2,
    CTIdiomWatch = 3,
    CTIdiomTV = 5,
    CTIdiomMac = 4
} CTIdiom;

typedef enum : long {
    CTSizeClassAny = 0,
    CTSizeClassCompact = 1,
    CTSizeClassRegular = 2
} CTSizeClass;

#endif
