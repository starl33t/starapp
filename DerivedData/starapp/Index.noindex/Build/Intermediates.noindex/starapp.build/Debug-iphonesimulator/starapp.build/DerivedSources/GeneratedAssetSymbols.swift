import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "DarkTwo" asset catalog color resource.
    static let darkTwo = DeveloperToolsSupport.ColorResource(name: "DarkTwo", bundle: resourceBundle)

    /// The "darkOne" asset catalog color resource.
    static let darkOne = DeveloperToolsSupport.ColorResource(name: "darkOne", bundle: resourceBundle)

    /// The "starBlack" asset catalog color resource.
    static let starBlack = DeveloperToolsSupport.ColorResource(name: "starBlack", bundle: resourceBundle)

    /// The "starMain" asset catalog color resource.
    static let starMain = DeveloperToolsSupport.ColorResource(name: "starMain", bundle: resourceBundle)

    /// The "whiteOne" asset catalog color resource.
    static let whiteOne = DeveloperToolsSupport.ColorResource(name: "whiteOne", bundle: resourceBundle)

    /// The "whiteTwo" asset catalog color resource.
    static let whiteTwo = DeveloperToolsSupport.ColorResource(name: "whiteTwo", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "DarkTwo" asset catalog color.
    static var darkTwo: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .darkTwo)
#else
        .init()
#endif
    }

    /// The "darkOne" asset catalog color.
    static var darkOne: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .darkOne)
#else
        .init()
#endif
    }

    /// The "starBlack" asset catalog color.
    static var starBlack: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .starBlack)
#else
        .init()
#endif
    }

    /// The "starMain" asset catalog color.
    static var starMain: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .starMain)
#else
        .init()
#endif
    }

    /// The "whiteOne" asset catalog color.
    static var whiteOne: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .whiteOne)
#else
        .init()
#endif
    }

    /// The "whiteTwo" asset catalog color.
    static var whiteTwo: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .whiteTwo)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "DarkTwo" asset catalog color.
    static var darkTwo: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .darkTwo)
#else
        .init()
#endif
    }

    /// The "darkOne" asset catalog color.
    static var darkOne: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .darkOne)
#else
        .init()
#endif
    }

    /// The "starBlack" asset catalog color.
    static var starBlack: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .starBlack)
#else
        .init()
#endif
    }

    /// The "starMain" asset catalog color.
    static var starMain: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .starMain)
#else
        .init()
#endif
    }

    /// The "whiteOne" asset catalog color.
    static var whiteOne: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .whiteOne)
#else
        .init()
#endif
    }

    /// The "whiteTwo" asset catalog color.
    static var whiteTwo: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .whiteTwo)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "DarkTwo" asset catalog color.
    static var darkTwo: SwiftUI.Color { .init(.darkTwo) }

    /// The "darkOne" asset catalog color.
    static var darkOne: SwiftUI.Color { .init(.darkOne) }

    /// The "starBlack" asset catalog color.
    static var starBlack: SwiftUI.Color { .init(.starBlack) }

    /// The "starMain" asset catalog color.
    static var starMain: SwiftUI.Color { .init(.starMain) }

    /// The "whiteOne" asset catalog color.
    static var whiteOne: SwiftUI.Color { .init(.whiteOne) }

    /// The "whiteTwo" asset catalog color.
    static var whiteTwo: SwiftUI.Color { .init(.whiteTwo) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "DarkTwo" asset catalog color.
    static var darkTwo: SwiftUI.Color { .init(.darkTwo) }

    /// The "darkOne" asset catalog color.
    static var darkOne: SwiftUI.Color { .init(.darkOne) }

    /// The "starBlack" asset catalog color.
    static var starBlack: SwiftUI.Color { .init(.starBlack) }

    /// The "starMain" asset catalog color.
    static var starMain: SwiftUI.Color { .init(.starMain) }

    /// The "whiteOne" asset catalog color.
    static var whiteOne: SwiftUI.Color { .init(.whiteOne) }

    /// The "whiteTwo" asset catalog color.
    static var whiteTwo: SwiftUI.Color { .init(.whiteTwo) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

