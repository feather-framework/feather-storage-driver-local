//
//  ServiceContextFactory+LocalStorageService.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIO
import FeatherService

public extension ServiceContextFactory {

    ///
    /// Creates a local configuration object based on the parameters
    ///
    /// - parameters:
    ///     - publicUrl: The public base URL used to resolve file keys (e.g. http://localhost/)
    ///     - publicPath: The path of the public asset storage on the server (e.g. /var/www/localhost/public/)
    ///     - workDirectory: The working directory name used to save assets (e.g. assets)
    ///     - posixMode: The posix file permission mode, default mode is `644`
    ///
    static func localStorage(
        threadPool: NIOThreadPool,
        eventLoopGroup: EventLoopGroup,
        path: String,
        posixMode: mode_t = 0o744,
        byteBufferAllocator: ByteBufferAllocator = .init()
    ) -> Self {
        .init {
            LocalStorageServiceContext(
                threadPool: threadPool,
                eventLoopGroup: eventLoopGroup,
                path: path,
                posixMode: posixMode,
                byteBufferAllocator: byteBufferAllocator
            )
        }
    }
}
