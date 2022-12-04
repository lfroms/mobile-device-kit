//
//  Device.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

/// The object you use to discover and interact with mobile devices connected to the system.
///
/// An instance of the `Device` object represents a single device connected to the system. A device
/// is ephemeral—it can be added or removed at any time depending on the type of connection (USB
/// or Wi-Fi).
///
/// The ``devices`` property returns an `AsyncStream` of all devices currently attached to the system
/// at the time of access.
public struct Device: Identifiable {
    public static var devices: [Device] {
        let deviceList = AMDCreateDeviceList()

        guard let items = deviceList?.takeUnretainedValue() as? [AnyObject] else {
            return []
        }

        return items.compactMap { item in
            let devicePointer = unsafeBitCast(item, to: AMDeviceRef.self)
            return Device(from: devicePointer)
        }
    }

    internal let device: AMDeviceRef

    public let id: String
}

// MARK: - Hashable

extension Device: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Device {
    init(from device: AMDeviceRef) {
        self.device = device
        self.id = AMDeviceCopyDeviceIdentifier(device).takeUnretainedValue() as String
    }
}
