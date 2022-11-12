import Foundation

/// An entity capable of installing apps.
public protocol AppInstallable {
    /// Installs the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    func installApp(bundleUrl: URL) throws
}
