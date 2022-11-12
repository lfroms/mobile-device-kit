import Combine
import Foundation
import MobileDeviceKit

@main
public enum MobileDeviceKitSample {
    private static var cancellables = Set<AnyCancellable>()

    public static func main() {
        let session = DeviceDiscoverySession()

        session.$devices
            .sink { devices in
                Task {
                    if let device = devices.first {
                        install(to: device)
                    }
                }
            }
            .store(in: &cancellables)

        RunLoop.main.run()
    }

    static func install(to device: Device) {
        try? device.transferApp(bundleUrl: URL(string: "file:///Users/lukas/Downloads/Clouds.app")!)
        try? device.installApp(bundleUrl: URL(string: "file:///Users/lukas/Downloads/Clouds.app")!)
    }
}
