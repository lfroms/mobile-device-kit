//
//  URL+ExpressibleByArgument.swift
//  MobileDeviceUtil
//
//  Created by Lukas Romsicki on 2022-12-03.
//  Copyright © 2022 Lukas Romsicki.
//

import Foundation
import ArgumentParser

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(filePath: NSString(string: argument).expandingTildeInPath)
    }
}
