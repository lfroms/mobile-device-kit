//
//  Install.swift
//  MobileDeviceUtil
//
//  Created by Lukas Romsicki on 2022-12-03.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import ArgumentParser
import MobileDeviceKit

struct Install: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Installs an application bundle to a device."
    )

    @Option(name: [.short, .long], help: "The path to the application bundle.")
    var bundlePath: Foundation.URL

    @Option(name: [.short, .long], help: "The full identifier (UDID) of the device to install the application to.")
    var deviceIdentifier: String

    func run() async throws {
        guard let device = Device.devices.first(where: { $0.id == deviceIdentifier }) else {
            print("Device with identifier \(deviceIdentifier) not found.")
            throw ExitCode.failure
        }

        try device.connect()
        try device.startSession()

        var lastStatusUpdate = ""
        for try await status in device.transferApp(bundleUrl: bundlePath) {
            let description = status.phase.description

            if description != lastStatusUpdate {
                print(status.phase.description)
            }

            lastStatusUpdate = description
        }

        for try await status in device.installApp(bundleUrl: bundlePath) {
            print(status.phase.description)
        }

        try device.stopSession()
        try device.disconnect()
    }
}

extension ApplicationTransferStatus.Phase: CustomStringConvertible {
    public var description: String {
        switch self {
            case .preflightingTransfer:
                return "Preflighting transfer"
            case .transferringPackage:
                return "Transferring package"
            case .copyingFile(let progress):
                return "Copying \(progress.currentFileURL.lastPathComponent)"
        }
    }
}

extension ApplicationInstallStatus.Phase: CustomStringConvertible {
    public var description: String {
        switch self {
            case .creatingStagingDirectory:
                return "Creating staging directory"
            case .extractingPackage:
                return "Extracting package"
            case .inspectingPackage:
                return "Inspecting package"
            case .preflightingApplication:
                return "Preflighting application"
            case .verifyingApplication:
                return "Verifying application"
            case .creatingContainer:
                return "Creating container"
            case .installingApplication:
                return "Installing application"
            case .postflightingApplication:
                return "Postflighting application"
            case .sandboxingApplication:
                return "Sandboxing application"
            case .generatingApplicationMap:
                return "Generating application map"
            case .installComplete:
                return "Install complete"
        }
    }
}
