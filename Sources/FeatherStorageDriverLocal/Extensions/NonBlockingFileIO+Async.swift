//
//  NonBlockingFileIO+Async
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIOCore
import NIOPosix

extension NonBlockingFileIO {

    func write(
        fileHandle: NIOFileHandle,
        buffer: ByteBuffer,
        eventLoop: EventLoop
    ) async throws {
        try await write(
            fileHandle: fileHandle,
            buffer: buffer,
            eventLoop: eventLoop
        )
        .get()
    }

    func openFile(
        path: String,
        mode: NIOFileHandle.Mode,
        flags: NIOFileHandle.Flags = .default,
        eventLoop: EventLoop
    ) async throws -> NIOFileHandle {
        try await openFile(
            path: path,
            mode: mode,
            flags: flags,
            eventLoop: eventLoop
        )
        .get()
    }

    func readFileSize(
        fileHandle: NIOFileHandle,
        eventLoop: EventLoop
    ) async throws -> Int64 {
        try await readFileSize(
            fileHandle: fileHandle,
            eventLoop: eventLoop
        )
        .get()
    }

    func read(
        fileHandle: NIOFileHandle,
        byteCount: Int,
        allocator: ByteBufferAllocator,
        eventLoop: EventLoop
    ) async throws -> ByteBuffer {
        try await read(
            fileHandle: fileHandle,
            byteCount: byteCount,
            allocator: allocator,
            eventLoop: eventLoop
        )
        .get()
    }
}
