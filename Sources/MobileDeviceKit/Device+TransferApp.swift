//
//  Device+TransferApp.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-20.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

private let notificationUserInfoStatusKey = "transferStatus"

private extension Notification.Name {
    static let applicationTransferStatusReported = Notification.Name("ApplicationTransferStatusReported")
}

public extension Device {
    /// Transfers the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    /// - Returns: An `AsyncThrowingStream` that reports progress during the transfer.
    func transferApp(bundleUrl: URL) -> AsyncThrowingStream<ApplicationTransferStatus, Error> {
        AsyncThrowingStream { continuation in
            Task {
                for await notification in NotificationCenter.default.notifications(named: .applicationTransferStatusReported) {
                    guard let status = notification.userInfo?[notificationUserInfoStatusKey] as? ApplicationTransferStatus else {
                        return
                    }

                    continuation.yield(status)
                }
            }

            Task {
                let error = AMDeviceSecureTransferPath(nil, device, bundleUrl as CFURL, nil, transferCallback, nil)

                guard error == kAMDSuccess else {
                    let message = AMDCopyErrorText(error).takeRetainedValue() as String
                    continuation.finish(throwing: DeviceError.failedToTransferApp(message: message))

                    return
                }

                continuation.finish()
            }
        }
    }
}

private let transferCallback: AMDeviceInstallationCallback = { dictionary, _ in
    guard
        let dictionary = dictionary as? [String: AnyObject],
        let transferStatus = ApplicationTransferStatus(from: dictionary)
    else {
        return
    }

    NotificationCenter.default.post(
        name: .applicationTransferStatusReported,
        object: nil,
        userInfo: [notificationUserInfoStatusKey: transferStatus]
    )
}

private extension ApplicationTransferStatus {
    init?(from dictionary: [String: AnyObject]) {
        guard
            let status = dictionary["Status"] as? String,
            let percentComplete = dictionary["PercentComplete"] as? Int
        else {
            return nil
        }

        let phase: ApplicationTransferStatus.Phase? = {
            switch status {
                case "PreflightingTransfer":
                    return .preflightingTransfer
                case "TransferringPackage":
                    return .transferringPackage
                case "CopyingFile":
                    guard
                        let totalFiles = dictionary["TotalFiles"] as? Int,
                        let totalBytes = dictionary["TotalBytes"] as? Int,
                        let copiedFiles = dictionary["NumFiles"] as? Int,
                        let copiedBytes = dictionary["NumBytes"] as? Int,
                        let path = dictionary["Path"] as? String
                    else {
                        return nil
                    }

                    let progress = FileCopyProgress(
                        totalFiles: totalFiles,
                        totalBytes: totalBytes,
                        copiedFiles: copiedFiles,
                        copiedBytes: copiedBytes,
                        currentFileURL: URL(filePath: path)
                    )

                    return .copyingFile(progress: progress)

                default:
                    return nil
            }
        }()

        guard let phase = phase else {
            return nil
        }

        self.percentComplete = percentComplete
        self.phase = phase
    }
}
