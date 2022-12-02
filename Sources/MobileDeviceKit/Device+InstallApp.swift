//
//  Device+InstallApp.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-01.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

public extension Device {
    /// Installs the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    func installApp(bundleUrl: URL) throws {
        var afcFd: AMDServiceConnectionRef?
        AMDeviceSecureStartService(device, "com.apple.afc" as CFString, nil, &afcFd)

        let installCallback: AMDeviceInstallationCallback = { dictionary, argument in
            print(dictionary as Any, argument as Any)
        }

        AMDeviceSecureInstallApplication(
            afcFd,
            device,
            bundleUrl as CFURL,
            ["PackageType": "Developer"] as CFDictionary,
            installCallback,
            nil
        )
    }
}
