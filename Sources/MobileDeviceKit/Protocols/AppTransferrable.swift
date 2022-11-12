import Foundation

/// An entity capable of transferring apps.
public protocol AppTransferrable {
    /// Transfers the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    func transferApp(bundleUrl: URL) throws
}
