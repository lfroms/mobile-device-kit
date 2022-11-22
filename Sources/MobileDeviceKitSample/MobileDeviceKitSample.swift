//
//  MobileDeviceKitSample.swift
//  MobileDeviceKitSample
//
//  Created by Lukas Romsicki on 2022-11-12.
//  Copyright © 2022 Lukas Romsicki. All rights reserved.
//

import Combine
import Foundation
import MobileDeviceKit

@main
public enum MobileDeviceKitSample {
    private static var cancellables = Set<AnyCancellable>()

    public static func main() async {
        for await device in Device.devices {
            print(device)
        }

        RunLoop.main.run()
    }
}
