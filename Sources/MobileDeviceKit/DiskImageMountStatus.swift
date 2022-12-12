//
//  DiskImageMountStatus.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-11.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation

/// Structure representing the current status of a disk image mounting operation on a device.
public struct DiskImageMountStatus {
    /// Structure representing the current phase of an install operation.
    public enum Phase {
        /// The image is being read from the file system.
        case lookingUpImage
        /// The image is being streamed to the device.
        case streamingImage
        /// Individual files are being copied.
        case copyingFile(progress: FileCopyProgress)
        /// The image is being mounted on the device
        case mountingImage
    }

    /// Percentage from 0 to 100% indicating the progress of the mounting operation.
    public let percentComplete: Int
    /// The current phase of the mounting operation.
    public let phase: Phase
}
