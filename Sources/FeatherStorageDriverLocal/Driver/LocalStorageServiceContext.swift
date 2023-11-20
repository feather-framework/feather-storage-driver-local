//
//  LocalStorageServiceContext.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIO
import FeatherService

public struct LocalStorageServiceContext: ServiceContext {

    let threadPool: NIOThreadPool
    let eventLoopGroup: EventLoopGroup
    let path: String
    let posixMode: mode_t
    let byteBufferAllocator: ByteBufferAllocator
    
    public init(
        threadPool: NIOThreadPool,
        eventLoopGroup: EventLoopGroup,
        path: String,
        posixMode: mode_t = 0o744,
        byteBufferAllocator: ByteBufferAllocator = .init()
    ) {
        self.threadPool = threadPool
        self.eventLoopGroup = eventLoopGroup
        self.path = path
        self.posixMode = posixMode
        self.byteBufferAllocator = byteBufferAllocator
    }

    public func createDriver() throws -> ServiceDriver {
        LocalStorageServiceDriver()
    }
}
