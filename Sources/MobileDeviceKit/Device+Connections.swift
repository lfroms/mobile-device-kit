//
//  Device+Connections.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-03.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

public extension Device {
    /// Starts a connection to the device.
    func connect() throws {
        let error = AMDeviceConnect(device)

        if error != kAMDSuccess {
            let message = AMDCopyErrorText(error).takeRetainedValue() as String
            throw DeviceError.failedToConnect(message: message)
        }
    }

    /// Stops a connection to the device.
    func disconnect() throws {
        let error = AMDeviceDisconnect(device)

        if error != kAMDSuccess {
            let message = AMDCopyErrorText(error).takeRetainedValue() as String
            throw DeviceError.failedToDisconnect(message: message)
        }
    }
}
