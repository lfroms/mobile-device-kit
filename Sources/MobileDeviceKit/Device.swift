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
    public static let devices = AsyncStream<Device> { continuation in
        Task(priority: .high) {
            let list = AMDCreateDeviceList()

            guard let items = list?.takeRetainedValue() as? [CFTypeRef] else {
                return continuation.finish()
            }

            items.forEach { item in
                let devicePointer = unsafeBitCast(item, to: AMDeviceRef.self)

                AMDeviceConnect(devicePointer)
                AMDeviceStartSession(devicePointer)

                defer {
                    AMDeviceStopSession(devicePointer)
                    AMDeviceDisconnect(devicePointer)
                }

                let device = Device(from: devicePointer)
                continuation.yield(device)
            }

            continuation.finish()
        }
    }

    internal let device: AMDeviceRef

    public let id: String
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

extension Device {
    init(from device: AMDeviceRef) {
        self.device = device

        id = AMDeviceCopyDeviceIdentifier(device).takeRetainedValue() as String

        let readProperty = { (name: String) in
            let resultRef = AMDeviceCopyValue(device, nil, name as CFString)
            return resultRef?.takeRetainedValue() as? String
        }

        deviceName = readProperty("DeviceName")

        buildVersion = readProperty("BuildVersion")
        deviceClass = readProperty("DeviceClass")
        deviceType = readProperty("DeviceType")
        hardwareModel = readProperty("HardwareModel")
        productType = readProperty("ProductType")
        productVersion = readProperty("ProductVersion")
    }
}
