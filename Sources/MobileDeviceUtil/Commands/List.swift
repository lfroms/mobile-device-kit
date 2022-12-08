//
//  List.swift
//  MobileDeviceUtil
//
//  Created by Lukas Romsicki on 2022-12-07.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import ArgumentParser
import MobileDeviceKit

struct List: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Lists the devices actively connected to the system."
    )

    func run() async throws {
        let devices = Device.devices
        
        for (index, device) in devices.enumerated() {
            print("\(index + 1)) \(device)")
        }
        
        if !devices.isEmpty {
            print()
        }
        
        print("\(devices.count) device(s) connected")
    }
}

extension Device: CustomStringConvertible {
    public var description: String {
        "Name: \(name), UDID: \(id), Type: \(productType), Version: \(productVersion), Connection: \(connection)"
    }
}

extension Device.Connection: CustomStringConvertible {
    public var description: String {
        switch self {
            case .wired:
                return "USB"
            case .wireless:
                return "Wi-Fi"
        }
    }
}
