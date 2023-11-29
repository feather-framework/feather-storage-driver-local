//
//  LocalStorageServiceBuilder.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bödecs on 2020. 04. 28..
//

import FeatherService

struct LocalStorageServiceBuilder: ServiceBuilder {

    func build(using config: ServiceConfig) throws -> Service {
        LocalStorageService(config: config)
    }
}
