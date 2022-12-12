//
//  FileCopyProgress.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-11.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation

/// Structure representing the progress of a file copy phase of a transfer operation.
public struct FileCopyProgress {
    /// The total number of files being copied to the destination.
    public let totalFiles: Int
    /// The total number of bytes being copied to the destination.
    public let totalBytes: Int
    /// The number of files copied so far.
    public let copiedFiles: Int
    /// The number of bytes copied so far.
    public let copiedBytes: Int
    /// The URL of the current file being copied.
    public let currentFileURL: URL
}
