//
//  Device.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki. All rights reserved.
//

import MobileDevice

/// A device that is connected to the system.
public struct Device: Identifiable {
    public typealias ID = String

    internal let _device: UnsafeMutablePointer<am_device>

    public let id: ID
    public let deviceName: String?
    public let buildVersion: String?
    public let deviceClass: String?
    public let deviceType: String?
    public let hardwareModel: String?
    public let productType: String?
    public let productVersion: String?
}

// MARK: - Hashable

extension Device: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
