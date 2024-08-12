#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.starleet.starappv01";

/// The "DarkTwo" asset catalog color resource.
static NSString * const ACColorNameDarkTwo AC_SWIFT_PRIVATE = @"DarkTwo";

/// The "darkOne" asset catalog color resource.
static NSString * const ACColorNameDarkOne AC_SWIFT_PRIVATE = @"darkOne";

/// The "starBlack" asset catalog color resource.
static NSString * const ACColorNameStarBlack AC_SWIFT_PRIVATE = @"starBlack";

/// The "starMain" asset catalog color resource.
static NSString * const ACColorNameStarMain AC_SWIFT_PRIVATE = @"starMain";

/// The "whiteOne" asset catalog color resource.
static NSString * const ACColorNameWhiteOne AC_SWIFT_PRIVATE = @"whiteOne";

/// The "whiteTwo" asset catalog color resource.
static NSString * const ACColorNameWhiteTwo AC_SWIFT_PRIVATE = @"whiteTwo";

#undef AC_SWIFT_PRIVATE
