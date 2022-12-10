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

    @Flag(name: [.short, .long], help: "Whether to continously observe and print device connection events.")
    var observe: Bool = false

    func run() async throws {
        if observe {
            for await event in Device.deviceEvents {
                let formattedDate = Date().formatted(date: .numeric, time: .standard)

                switch event {
                    case .connected(let device):
                        print("[\(formattedDate)] Connected: \(device)")
                    case .disconnected(let deviceIdentifier):
                        print("[\(formattedDate)] Disconnected: \(deviceIdentifier)")
                }
            }

            return
        }

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
        "\(name), UDID: \(id), Type: \(productType), Version: \(productVersion), Interface: \(interface)"
    }
}

extension Device.Interface: CustomStringConvertible {
    public var description: String {
        switch self {
            case .wired:
                return "USB"
            case .wireless:
                return "Wi-Fi"
        }
    }
}
