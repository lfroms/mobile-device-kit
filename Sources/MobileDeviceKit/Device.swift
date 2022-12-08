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
/// The ``devices`` property returns an array of all devices currently attached to the system.
public struct Device: Identifiable, Hashable {
    /// The type of connection by which the device interfaces with the system.
    public enum Connection {
        /// The device is connected through a physical connection like USB or FireWire.
        case wired
        /// The device is connected wirelessly over Wi-Fi.
        case wireless
    }

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

    let device: AMDeviceRef

    /// The unique identifier (UDID) of the device.
    public let id: String

    /// The type of connection by which the device interfaces with the system.
    public let connection: Connection

    /// The name of the device.
    public let name: String

    /// The build version of the operating system installed on the device.
    public let buildVersion: String

    /// The product type of the device (e.g. `iPhone12,3`).
    public let productType: String

    /// The product version of the operating system installed on the device.
    public let productVersion: String

    /// The device class (e.g. `iPhone` or `iPad`).
    public let deviceClass: String

    /// Whether developer mode is enabled on the device.
    public let developerModeEnabled: Bool
}

extension Device {
    init(from device: AMDeviceRef) {
        self.device = device
        self.id = AMDeviceCopyDeviceIdentifier(device).takeRetainedValue() as String
        self.connection = Connection(rawValue: AMDeviceGetInterfaceType(device))
        
        AMDeviceConnect(device)
        AMDeviceStartSession(device)
        
        self.name = AMDeviceCopyValue(device, nil, kAMDDeviceNameKey as CFString).takeRetainedValue() as! String
        self.buildVersion = AMDeviceCopyValue(device, nil, kAMDBuildVersionKey as CFString).takeRetainedValue() as! String
        self.productType = AMDeviceCopyValue(device, nil, kAMDProductTypeKey as CFString).takeRetainedValue() as! String
        self.productVersion = AMDeviceCopyValue(device, nil, kAMDProductVersionKey as CFString).takeRetainedValue() as! String
        self.deviceClass = AMDeviceCopyValue(device, nil, kAMDDeviceClassKey as CFString).takeRetainedValue() as! String

        self.developerModeEnabled = AMDeviceCopyDeveloperModeStatus(device, nil)

        AMDeviceStopSession(device)
        AMDeviceDisconnect(device)
    }
}

private extension Device.Connection {
    init(rawValue: AMDeviceInterfaceType) {
        switch rawValue {
            case kAMDeviceInterfaceWired:
                self = .wired
            case kAMDeviceInterfaceWireless:
                self = .wireless
            default:
                fatalError("Unexpected device interface type: \(rawValue)")
        }
    }
}
