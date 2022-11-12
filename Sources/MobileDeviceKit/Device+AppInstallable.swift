//
//  Device+AppInstallable.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki. All rights reserved.
//

import Foundation
import MobileDevice

extension Device: AppInstallable {
    public func installApp(bundleUrl: URL) throws {
        AMDeviceConnect(_device)
        AMDeviceValidatePairing(_device)
        AMDeviceStartSession(_device)

        defer {
            AMDeviceStopSession(_device)
            AMDeviceDisconnect(_device)
        }

        var afcFd: ServiceConnRef?
        AMDeviceSecureStartService(_device, "com.apple.afc" as CFString, nil, &afcFd)

        AMDeviceSecureInstallApplication(
            0,
            _device,
            bundleUrl as CFURL,
            ["PackageType": "Developer"] as CFDictionary,
            installCallbackPointer,
            0
        )
    }
}
