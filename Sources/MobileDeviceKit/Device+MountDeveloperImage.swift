//
//  Device+MountDeveloperDiskImage.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-11.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

private let notificationUserInfoStatusKey = "mountStatus"

private extension Notification.Name {
    static let diskImageMountStatusReported = Notification.Name("DiskImageMountStatusReported")
}

extension Device {
    public func mountDeveloperDiskImage(url: URL, signatureURL: URL) -> AsyncThrowingStream<DiskImageMountStatus, Error>  {
        AsyncThrowingStream { continuation in
            Task {
                for await notification in NotificationCenter.default.notifications(named: .diskImageMountStatusReported) {
                    guard let status = notification.userInfo?[notificationUserInfoStatusKey] as? DiskImageMountStatus else {
                        return
                    }

                    continuation.yield(status)
                }
            }

            Task {
                guard let signatureData = try? Data(contentsOf: signatureURL) else {
                    continuation.finish(throwing: DeviceError.failedToLoadDiskImageSignature)
                    return
                }

                let options = [
                    kAMDImageTypeKey: kAMDImageTypeDeveloper,
                    kAMDImageSignatureKey: signatureData
                ]

                let error = AMDeviceMountImage(device, url.path() as CFString, options as CFDictionary, mountCallback, nil)

                guard error == kAMDSuccess else {
                    let message = AMDCopyErrorText(error).takeRetainedValue() as String
                    continuation.finish(throwing: DeviceError.failedToMountDiskImage(message: message))

                    return
                }

                continuation.finish()
            }
        }
    }
}

private let mountCallback: AMDeviceInstallationCallback = { dictionary, _ in
    guard
        let dictionary = dictionary as? [String: AnyObject],
        let mountStatus = DiskImageMountStatus(from: dictionary)
    else {
        return
    }

    NotificationCenter.default.post(
        name: .diskImageMountStatusReported,
        object: nil,
        userInfo: [notificationUserInfoStatusKey: mountStatus]
    )
}

private extension DiskImageMountStatus {
    init?(from dictionary: [String: AnyObject]) {
        guard let status = dictionary["Status"] as? String else {
            return nil
        }

        let phase: DiskImageMountStatus.Phase? = {
            switch status {
                case "LookingUpImage":
                    return .lookingUpImage
                case "StreamingImage":
                    return .streamingImage
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
                case "MountingImage":
                    return .mountingImage
                default:
                    return nil
            }
        }()

        guard let phase = phase else {
            return nil
        }

        let overallPercentComplete: Int = {
            switch phase {
                case .lookingUpImage:
                    return 0
                case .streamingImage:
                    return 1
                case .copyingFile:
                    return dictionary["PercentComplete"] as? Int ?? 0
                case .mountingImage:
                    return 100
            }
        }()

        self.percentComplete = overallPercentComplete
        self.phase = phase
    }
}
