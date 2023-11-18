//
//  LocalStorageServiceDriver.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import FeatherService

struct LocalStorageServiceDriver: ServiceDriver {

    func run(using config: ServiceConfig) throws -> Service {
        LocalStorageService(config: config)
    }
}
