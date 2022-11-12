import Combine
import Foundation
import MobileDevice

/// When initialized, creates a device discovery session and subscribes to device attach or detach events.
open class DeviceDiscoverySession {
    /// The devices currently connected to the system.
    @Published public private(set) var devices: [Device] = []

    private var cancellables = Set<AnyCancellable>()

    private var notification: UnsafeMutablePointer<am_device_notification>?
    private var callback: am_device_notification_callback = { info, cookie in
        NotificationCenter.default.post(name: .deviceConnected, object: info)
    }

    public init() {
        NotificationCenter.default
            .publisher(for: .deviceConnected)
            .compactMap { $0.object as? UnsafeMutablePointer<am_device_notification_callback_info> }
            .sink { [weak self] info in
                guard let self = self, let devicePointer = info.pointee.dev else {
                    return
                }

                switch Int32(info.pointee.msg) {
                    case ADNCI_MSG_CONNECTED:
                        AMDeviceConnect(devicePointer)
                        AMDeviceStartSession(devicePointer)

                        defer {
                            AMDeviceStopSession(devicePointer)
                            AMDeviceDisconnect(devicePointer)
                        }

                        let device = Device(from: devicePointer)

                        guard !self.devices.contains(device) else {
                            return
                        }

                        self.devices.append(device)

                    case ADNCI_MSG_DISCONNECTED:
                        // UDID can be retrieved without connecting.
                        let device = Device(from: devicePointer)
                        self.devices.removeAll { $0.id == device.id }

                    default:
                        break
                }
            }
            .store(in: &cancellables)

        AMDeviceNotificationSubscribeWithOptions(callback, 0, 0, nil, &notification, nil)
    }

    deinit {
        AMDeviceNotificationUnsubscribe(callback)
    }
}

private extension Notification.Name {
    static let deviceConnected = Self(rawValue: "deviceConnected")
}

private extension Device {
    init(from device: UnsafeMutablePointer<am_device>) {
        _device = device

        id = AMDeviceCopyDeviceIdentifier(device).takeRetainedValue() as String

        let readProperty = { (name: String) in
            let resultRef = AMDeviceCopyValue(device, nil, name as CFString)
            return resultRef?.takeRetainedValue() as? String
        }

        deviceName = readProperty("DeviceName")
        buildVersion = readProperty("BuildVersion")
        deviceClass = readProperty("DeviceClass")
        deviceType = readProperty("DeviceType")
        hardwareModel = readProperty("HardwareModel")
        productType = readProperty("ProductType")
        productVersion = readProperty("ProductVersion")
    }
}
