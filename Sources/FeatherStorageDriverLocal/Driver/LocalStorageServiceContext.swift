//
//  LocalStorageServiceContext.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIO
import FeatherService

struct LocalStorageServiceContext: ServiceContext {

    let threadPool: NIOThreadPool

    let eventLoopGroup: EventLoopGroup

    let path: String

    let posixMode: mode_t

    let byteBufferAllocator: ByteBufferAllocator

    func createDriver() throws -> ServiceDriver {
        LocalStorageServiceDriver()
    }

}
