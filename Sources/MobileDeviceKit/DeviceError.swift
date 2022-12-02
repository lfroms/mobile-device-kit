//
//  DeviceError.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-01.
//  Copyright © 2022 Lukas Romsicki.
//

public enum DeviceError: Error {
    case failedToTransferApp(message: String)
}
