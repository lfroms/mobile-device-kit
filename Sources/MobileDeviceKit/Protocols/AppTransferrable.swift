//
//  AppTransferrable.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki. All rights reserved.
//

import Foundation

/// An entity capable of transferring apps.
public protocol AppTransferrable {
    /// Transfers the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    func transferApp(bundleUrl: URL) throws
}
