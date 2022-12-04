//
//  Device+InstallApp.swift
//  MobileDeviceKit
//
//  Created by Lukas Romsicki on 2022-12-01.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import MobileDevice

private let notificationUserInfoStatusKey = "installStatus"

private extension Notification.Name {
    static let applicationInstallStatusReported = Notification.Name("ApplicationInstallStatusReported")
}

public extension Device {
    /// Installs the app at the given URL to the device.
    /// - Parameter bundleUrl: The URL at which the app bundle is located.
    /// - Returns: An `AsyncThrowingStream` that reports progress during the transfer.
    func installApp(bundleUrl: URL) -> AsyncThrowingStream<ApplicationInstallStatus, Error> {
        AsyncThrowingStream { continuation in
            Task {
                for await notification in NotificationCenter.default.notifications(named: .applicationInstallStatusReported) {
                    guard let status = notification.userInfo?[notificationUserInfoStatusKey] as? ApplicationInstallStatus else {
                        return
                    }

                    continuation.yield(status)
                }
            }
         
            Task {
                var afcFd: AMDServiceConnectionRef?
                let serviceStartError = AMDeviceSecureStartService(device, kAFCServiceName as CFString, nil, &afcFd)

                guard serviceStartError == kAMDSuccess else {
                    let message = AMDCopyErrorText(serviceStartError).takeRetainedValue() as String
                    continuation.finish(throwing: DeviceError.failedToStartService(serviceName: kAFCServiceName, message: message))

                    return
                }

                let packageType: String? = {
                    switch bundleUrl.pathExtension {
                        case "app":
                            return kAMDPackageTypeDeveloper
                        case "ipa":
                            return kAMDPackageTypeCustomer
                        default:
                            return nil
                    }
                }()

                let error = AMDeviceSecureInstallApplication(
                    nil,
                    device,
                    bundleUrl as CFURL,
                    [kAMDPackageTypeKey: packageType] as CFDictionary,
                    installCallback,
                    nil
                )

                guard error == kAMDSuccess else {
                    let message = AMDCopyErrorText(error).takeRetainedValue() as String
                    continuation.finish(throwing: DeviceError.failedToInstallApp(message: message))

                    return
                }

                continuation.finish()
            }
        }
    }
}

private let installCallback: AMDeviceInstallationCallback = { dictionary, _ in
    guard
        let dictionary = dictionary as? [String: AnyObject],
        let installStatus = ApplicationInstallStatus(from: dictionary)
    else {
        return
    }

    NotificationCenter.default.post(
        name: .applicationInstallStatusReported,
        object: nil,
        userInfo: [notificationUserInfoStatusKey: installStatus]
    )
}

private extension ApplicationInstallStatus {
    init?(from dictionary: [String: AnyObject]) {
        guard
            let status = dictionary["Status"] as? String,
            let percentComplete = dictionary["PercentComplete"] as? Int
        else {
            return nil
        }

        let phase: ApplicationInstallStatus.Phase? = {
            switch status {
                case "CreatingStagingDirectory":
                    return .creatingStagingDirectory
                case "ExtractingPackage":
                    return .extractingPackage
                case "InspectingPackage":
                    return .inspectingPackage
                case "PreflightingApplication":
                    return .preflightingApplication
                case "VerifyingApplication":
                    return .verifyingApplication
                case "CreatingContainer":
                    return .creatingContainer
                case "InstallingApplication":
                    return .installingApplication
                case "PostflightingApplication":
                    return .postflightingApplication
                case "SandboxingApplication":
                    return .sandboxingApplication
                case "GeneratingApplicationMap":
                    return .generatingApplicationMap
                case "InstallComplete":
                    return .installComplete
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
