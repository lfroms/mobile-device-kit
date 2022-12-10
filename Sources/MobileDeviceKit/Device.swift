//
//  Device.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

private let notificationUserInfoDevice = "device"
private let notificationUserInfoDeviceIdentifier = "deviceIdentifier"

private extension Notification.Name {
    static let deviceConnected = Notification.Name(rawValue: "deviceConnected")
    static let deviceDisconnected = Notification.Name(rawValue: "deviceDisconnected")
    static let deviceNotificationsEnded = Notification.Name(rawValue: "deviceNotificationsEnded")
}

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
    
    /// An event occurs when a device connects or disconnects from the system.
    public enum Event {
        /// A device has connected to the system.
        case connected(device: Device)
        /// A device with the given identifier has disconnected from the system.
        case disconnected(deviceIdentifier: String)
    }

    /// An array of all devices currently attached to the system.
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

    /// An asynchronous sequence you use to observe changes to devices as they are connected or disconnected
    /// from the system.
    ///
    /// Take care not to cache these values as devices may be connected or disconnected any time. Ensure that references
    /// to disconnected devices are cleared as soon as they are no longer available.
    public static var deviceEvents: AsyncStream<Event> {
        AsyncStream { continuation in
            Task {
                for await notification in NotificationCenter.default.notifications(named: .deviceConnected) {
                    guard let deviceRef = notification.userInfo?[notificationUserInfoDevice] as? AMDeviceRef else {
                        return
                    }
                    
                    let device = Device(from: deviceRef)
                    continuation.yield(.connected(device: device))
                }
            }

            Task {
                for await notification in NotificationCenter.default.notifications(named: .deviceDisconnected) {
                    guard let deviceRef = notification.userInfo?[notificationUserInfoDevice] as? AMDeviceRef else {
                        return
                    }
                    
                    let identifier = AMDeviceCopyDeviceIdentifier(deviceRef).takeRetainedValue() as String
                    continuation.yield(.disconnected(deviceIdentifier: identifier))
                }
            }

            Task {
                for await _ in NotificationCenter.default.notifications(named: .deviceNotificationsEnded) {
                    continuation.finish()
                }
            }

            Task.detached { @MainActor in
                var notification: AMDeviceNotificationRef?
                let error = AMDeviceNotificationSubscribeWithOptions(notificationCallback, 0, kAMDeviceInterfaceAny, nil, &notification, nil)

                guard error == kAMDSuccess else {
                    continuation.finish()
                    return
                }

                continuation.onTermination = { @Sendable _ in
                    Task.detached { @MainActor in
                        AMDeviceNotificationUnsubscribe(notification)
                    }
                }
            }
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

private let notificationCallback: AMDeviceNotificationCallback = { info, _ in
    guard let info = info else {
        return
    }
    
    switch info.pointee.event {
        case kAMDeviceConnected:
            guard let deviceRef = info.pointee.device else {
                break
            }
            
            NotificationCenter.default.post(
                name: .deviceConnected,
                object: nil,
                userInfo: [
                    notificationUserInfoDevice: deviceRef
                ]
            )
        
        case kAMDeviceDisconnected:
            guard let deviceRef = info.pointee.device else {
                break
            }

            NotificationCenter.default.post(
                name: .deviceDisconnected,
                object: nil,
                userInfo: [
                    notificationUserInfoDevice: deviceRef
                ]
            )
            
        case kAMDeviceUnsubscribed:
            NotificationCenter.default.post(name: .deviceNotificationsEnded, object: nil)
            
        default:
            break
    }
}
