//
//  Device+StartServuce.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-07.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

public extension Device {
    /// Starts a service on the device.
    /// - Parameter service: The service to start.
    func start(service: Service) throws {
        let error = AMDeviceSecureStartService(device, service.name as CFString, nil, nil)

        if error != kAMDSuccess {
            let message = AMDCopyErrorText(error).takeRetainedValue() as String
            throw DeviceError.failedToStartService(serviceName: kAFCServiceName, message: message)
        }
    }
}

public enum Service {
    case appleFileConduit
}

private extension Service {
    var name: String {
        switch self {
            case .appleFileConduit:
                return kAFCServiceName
        }
    }
}
