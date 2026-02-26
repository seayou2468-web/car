#ifndef CTConstants_h
#define CTConstants_h

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
    CTAttributeAppearance = 23
} CTAttribute;

#endif
