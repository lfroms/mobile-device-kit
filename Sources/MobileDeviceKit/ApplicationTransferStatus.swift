//
//  ApplicationTransferStatus.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-01.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation

/// Structure representing the current status of an application transfer operation to a device.
public struct ApplicationTransferStatus {
    /// Structure representing the current phase of a transfer operation.
    public enum Phase {
        /// Initial checks are being performed before transferring the application.
        case preflightingTransfer
        /// The application package is being transferred.
        case transferringPackage
        /// Individual files are being copied.
        case copyingFile(progress: FileCopyProgress)
    }

    /// Percentage from 0 to 100% indicating the progress of the transfer operation.
    public let percentComplete: Int
    /// The current phase of the transfer operation.
    public let phase: Phase
}
