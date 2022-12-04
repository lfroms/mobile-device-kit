//
//  Device+Sessions.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-03.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

public extension Device {
    /// Starts a session with the device.
    func startSession() throws {
        let error = AMDeviceStartSession(device)

        if error != kAMDSuccess {
            let message = AMDCopyErrorText(error).takeRetainedValue() as String
            throw DeviceError.failedToStartSession(message: message)
        }
    }

    /// Stops a session with the device.
    func stopSession() throws {
        let error = AMDeviceStopSession(device)

        if error != kAMDSuccess {
            let message = AMDCopyErrorText(error).takeRetainedValue() as String
            throw DeviceError.failedToStopSession(message: message)
        }
    }
}
