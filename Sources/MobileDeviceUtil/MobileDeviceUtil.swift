//
//  MobileDeviceUtil.swift
//  MobileDeviceUtil
//
//  Created by Lukas Romsicki on 2022-12-03.
//  Copyright © 2022 Lukas Romsicki.
//

import ArgumentParser

@main
struct MobileDeviceUtil: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "deviceutil",
        abstract: "A utility for interacting with Apple mobile devices connected to the system.",
        subcommands: [Install.self]
    )
}
