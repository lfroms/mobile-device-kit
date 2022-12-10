//
//  Device+Devices.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Lukas Romsicki.
//

import MobileDevice

extension Device {
    /// An array of all devices currently attached to the system.
    ///
    /// Take care not to cache these values as devices may be connected or disconnected any time. Ensure that references
    /// to disconnected devices are cleared as soon as they are no longer available.
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
}
