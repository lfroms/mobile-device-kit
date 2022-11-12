//
//  AppInstallable.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki. All rights reserved.
//

import Foundation

/// An entity capable of installing apps.
public protocol AppInstallable {
    /// Installs the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    func installApp(bundleUrl: URL) throws
}
