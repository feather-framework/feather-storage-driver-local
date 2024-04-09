//
//  LocalStorageComponentContext.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bödecs on 2020. 04. 28..
//

import FeatherComponent
import NIO

public struct LocalStorageComponentContext: ComponentContext {

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

    public func make() throws -> ComponentFactory {
        LocalStorageComponentFactory()
    }
}
