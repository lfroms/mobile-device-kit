import Foundation
import MobileDevice

extension Device: AppTransferrable {
    public func transferApp(bundleUrl: URL) throws {
        AMDeviceSecureTransferPath(
            0,
            _device,
            bundleUrl as CFURL,
            ["PackageType": "Developer"] as CFDictionary,
            installCallbackPointer,
            0
        )
    }
}

typealias InstallCallback = @convention(c) (CFDictionary, Int32) -> Int32

let installCallback: InstallCallback = { dictionary, argument in
    print(dictionary, argument)
    return 0
}

let installCallbackPointer = unsafeBitCast(installCallback, to: UnsafeMutableRawPointer.self)
