//
//  DeviceDiscoverySession.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki.
//

import Combine
import Foundation
import MobileDevice

open class DeviceDiscoverySession: NSObject {
    /// The devices currently connected to the system.
    @Published open private(set) var devices: [Device] = []

    private var cancellables = Set<AnyCancellable>()

    private var notification: AMDeviceNotificationRef?
    private var callback: AMDeviceNotificationCallback = { info, _ in
        NotificationCenter.default.post(name: .deviceConnectionChanged, object: info)
    }

    override public init() {
        super.init()

        NotificationCenter.default
            .publisher(for: .deviceConnectionChanged)
            .compactMap { $0.object as? UnsafeMutablePointer<AMDeviceNotificationInfo> }
            .sink { [weak self] info in
                guard let self = self, let devicePointer = info.pointee.device else {
                    return
                }

                switch info.pointee.event {
                    case kAMDeviceConnected:
                        let device = Device(from: devicePointer)

                        guard !self.devices.contains(device) else {
                            return
                        }

                        self.devices.append(device)

                    case kAMDeviceDisconnected:
                        // UDID can be retrieved without connecting.
                        let device = Device(from: devicePointer)
                        self.devices.removeAll { $0.id == device.id }

                    default:
                        break
                }
            }
            .store(in: &cancellables)

        AMDeviceNotificationSubscribeWithOptions(callback, 0, kAMDeviceInterfaceAny, nil, &notification, nil)
    }

    deinit {
        AMDeviceNotificationUnsubscribe(notification)
    }
}

extension Notification.Name {
    static let deviceConnectionChanged = Self(rawValue: "deviceConnectionChanged")
}
