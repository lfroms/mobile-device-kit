//
//  Device+DeviceEvents.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-09.
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

extension Device {
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
}

extension Device {
    /// An event occurs when a device connects or disconnects from the system.
    public enum Event {
        /// A device has connected to the system.
        case connected(device: Device)
        /// A device with the given identifier has disconnected from the system.
        case disconnected(deviceIdentifier: String)
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
