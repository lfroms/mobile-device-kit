//
//  ApplicationInstallStatus.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-03.
//  Copyright © 2022 Lukas Romsicki.
//

/// Structure representing the current status of an application install operation to a device.
public struct ApplicationInstallStatus {
    /// Structure representing the current phase of an install operation.
    public enum Phase {
        /// A temporary working directory is being created on the device.
        case creatingStagingDirectory
        /// The pacakge is being extracted.
        case extractingPackage
        /// The package is being inspected.
        case inspectingPackage
        /// Initial checks are being performed before installing the application.
        case preflightingApplication
        /// The application is being verified,
        case verifyingApplication
        /// A container for the application is being created on the device.
        case creatingContainer
        /// The application is being installed on the device.
        case installingApplication
        /// Post installation checks are being performed.
        case postflightingApplication
        /// The application is being sandboxed on the device.
        case sandboxingApplication
        /// An application map is being generated.
        case generatingApplicationMap
        /// The installation has concluded.
        case installComplete
    }

    /// Percentage from 0 to 100% indicating the progress of the install operation.
    public let percentComplete: Int
    /// The current phase of the install operation.
    public let phase: Phase
}
