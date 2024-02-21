//
//  LocalStorageComponentBuilder.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bödecs on 2020. 04. 28..
//

import FeatherComponent

struct LocalStorageComponentBuilder: ComponentBuilder {

    func build(using config: ComponentConfig) throws -> Component {
        LocalStorageComponent(config: config)
    }
}
