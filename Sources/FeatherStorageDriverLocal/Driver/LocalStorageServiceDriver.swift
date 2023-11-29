//
//  LocalStorageServiceDriver.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bödecs on 2020. 04. 28..
//

import FeatherService

struct LocalStorageServiceDriver: ServiceBuilder {

    func build(using config: ServiceConfig) throws -> Service {
        LocalStorageService(config: config)
    }
}
