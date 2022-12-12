//
//  DeviceError.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-01.
//  Copyright © 2022 Lukas Romsicki.
//

/// Error that may be produced by a device.
public enum DeviceError: Error {
    case failedToTransferApp(message: String)
    case failedToStartService(serviceName: String, message: String)
    case invalidPackageType
    case failedToInstallApp(message: String)
    case failedToConnect(message: String)
    case failedToDisconnect(message: String)
    case failedToStartSession(message: String)
    case failedToStopSession(message: String)
    case failedToLoadDiskImageSignature
    case failedToMountDiskImage(message: String)
}
