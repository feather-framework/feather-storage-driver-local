//
//  LocalStorageService.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import Foundation
import NIO
import NIOFoundationCompat
import FeatherService
import FeatherStorage

@dynamicMemberLookup
struct LocalStorageService {

    let config: ServiceConfig

    subscript<T>(
        dynamicMember keyPath: KeyPath<LocalStorageServiceContext, T>
    ) -> T {
        let context = config.context as! LocalStorageServiceContext
        return context[keyPath: keyPath]
    }

    init(config: ServiceConfig) {
        self.config = config
    }
}

private extension LocalStorageService {

    func url(for key: String?) -> URL {
        .init(
            fileURLWithPath: self.path
        )
        .appendingPathComponent(key ?? "")
    }
}

extension LocalStorageService: StorageService {

    public var availableSpace: UInt64 {
        .max
    }

    public func upload(
        key: String,
        buffer: ByteBuffer
    ) async throws {
        let fileUrl = url(for: key)
        let location = fileUrl.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: location,
            permission: self.posixMode
        )

        let fileio = NonBlockingFileIO(threadPool: self.threadPool)
        let handle = try await fileio.openFile(
            path: fileUrl.path,
            mode: .write,
            flags: .allowFileCreation(),
            eventLoop: self.eventLoopGroup.any()
        )
        do {
            try await fileio.write(
                fileHandle: handle,
                buffer: buffer,
                eventLoop: self.eventLoopGroup.any()
            )
            try handle.close()
        }
        catch {
            try handle.close()
            throw error
        }
    }

    public func download(
        key: String,
        range: ClosedRange<UInt>?
    ) async throws -> ByteBuffer {
        let exists = await exists(key: key)
        guard exists else {
            throw StorageServiceError.invalidKey
        }
        let sourceUrl = url(for: key)
        let fileio = NonBlockingFileIO(threadPool: self.threadPool)
        let handle = try await fileio.openFile(
            path: sourceUrl.path,
            mode: .read,
            eventLoop: self.eventLoopGroup.any()
        )
        do {
            let size = try await fileio.readFileSize(
                fileHandle: handle,
                eventLoop: self.eventLoopGroup.any()
            )

            let buffer = try await fileio.read(
                fileHandle: handle,
                byteCount: Int(size),
                allocator: .init(),
                eventLoop: self.eventLoopGroup.any()
            )
            try handle.close()
            return buffer
        }
        catch {
            try handle.close()
            throw error
        }
    }

    public func exists(key: String) async -> Bool {
        FileManager.default.fileExists(atPath: url(for: key).path)
    }

    public func size(key: String) async -> UInt64 {
        0
    }

    public func copy(
        key source: String,
        to destination: String
    ) async throws {
        let exists = await exists(key: source)
        guard exists else {
            throw StorageServiceError.invalidKey
        }
        try await delete(key: destination)
        let sourceUrl = url(for: source)
        let destinationUrl = url(for: destination)
        let location = destinationUrl.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: location,
            permission: self.posixMode
        )
        try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
    }

    public func list(key: String?) async throws -> [String] {
        let dirUrl = url(for: key ?? "")
        if FileManager.default.directoryExists(at: dirUrl) {
            return try FileManager.default.contentsOfDirectory(
                atPath: dirUrl.path
            )
        }
        return []
    }

    public func delete(key: String) async throws {
        guard await exists(key: key) else {
            return
        }
        try FileManager.default.removeItem(atPath: url(for: key).path)
    }

    public func create(key: String) async throws {
        try FileManager.default.createDirectory(
            at: url(for: key),
            withIntermediateDirectories: true
        )
    }

    public func createMultipartId(
        key: String
    ) async throws -> String {
        ""
    }

    public func upload(
        multipartId: String,
        key: String,
        number: Int,
        buffer: ByteBuffer
    ) async throws -> Multipart.Chunk {
        .init(chunkId: "", number: 0)
    }

    public func abort(
        multipartId: String,
        key: String
    ) async throws {

    }

    public func finish(
        multipartId: String,
        key: String,
        chunks: [Multipart.Chunk]
    ) async throws {

    }

    //    func getAvailableSpace() -> UInt64 {
    //        let attributes = try? FileManager.default.attributesOfFileSystem(
    //            forPath: NSHomeDirectory() as String
    //        )
    //        let freeSpace = (attributes?[.systemFreeSize] as? NSNumber)?.int64Value
    //        return UInt64(freeSpace ?? 0)
    //    }
    //
    //    func resolve(
    //        key: String
    //    ) -> String {
    //        baseUrl.appendingPathComponent(key).absoluteString
    //    }
    //
    //    func download(
    //        key: String,
    //        range: ClosedRange<UInt>?,
    //        timeout: TimeAmount
    //    ) async throws -> ByteBuffer {
    //        let sourceUrl = basePath.appendingPathComponent(key)
    //        guard let handle = FileHandle(forReadingAtPath: sourceUrl.path) else {
    //            throw StorageServiceError.invalidKey
    //        }
    //        let attr = try FileManager.default.attributesOfItem(atPath: sourceUrl.path)
    //        let fileSize = attr[FileAttributeKey.size] as! UInt64
    //
    //        guard let range, range.upperBound <= fileSize else {
    //            return .init(data: handle.readData(ofLength: Int(fileSize)))
    //        }
    //        let size = Int(range.upperBound - range.lowerBound)
    //        try handle.seek(toOffset: UInt64(range.lowerBound))
    //        return .init(data: handle.readData(ofLength: size))
    //    }
    //
    //    func download(
    //        key: String,
    //        chunkSize: UInt,
    //        timeout: TimeAmount
    //    ) -> AsyncThrowingStream<ByteBuffer, Error> {
    //        .init { c in
    //            Task {
    //                let sourceUrl = basePath.appendingPathComponent(key)
    //                guard let handle = FileHandle(forReadingAtPath: sourceUrl.path) else {
    //                    throw StorageServiceError.invalidKey
    //                }
    //                let attr = try FileManager.default.attributesOfItem(atPath: sourceUrl.path)
    //                let fileSize = attr[FileAttributeKey.size] as! UInt64
    //                let bufSize = UInt64(chunkSize)
    //                var num = fileSize / bufSize
    //                let rem = fileSize % bufSize
    //                if rem > 0 {
    //                    num += 1
    //                }
    //
    //                for i in 0..<num {
    //                    let data: Data
    //                    try handle.seek(toOffset: bufSize * i)
    //                    if i == num - 1 {
    //                        data = handle.readData(ofLength: Int(rem))
    //                    }
    //                    else {
    //                        data = handle.readData(ofLength: Int(bufSize))
    //                    }
    //                    c.yield(.init(data: data))
    //                }
    //                c.finish()
    //            }
    //        }
    //    }
    //
    //    func upload(
    //        key: String,
    //        buffer: ByteBuffer,
    //        checksum: String?,
    //        timeout: TimeAmount
    //    ) async throws {
    //        let fileUrl = basePath.appendingPathComponent(key)
    //        let location = fileUrl.deletingLastPathComponent()
    //        try createDir(at: location)
    //
    //        if let checksum {
    //            let calculator = createChecksumCalculator()
    //            if let data = buffer.getData(at: 0, length: buffer.readableBytes) {
    //                calculator.update(.init(data))
    //            }
    //            if checksum != calculator.finalize() {
    //                throw StorageServiceError.invalidChecksum
    //            }
    //        }
    //
    //        return try await fileio.openFile(
    //            path: fileUrl.path,
    //            mode: .write,
    //            flags: .allowFileCreation(posixMode: posixMode),
    //            eventLoop: context.eventLoop
    //        )
    //        .flatMap { handle in
    //            fileio.write(
    //                fileHandle: handle,
    //                buffer: buffer,
    //                eventLoop: context.eventLoop
    //            )
    //            .flatMapThrowing { _ in
    //                try handle.close()
    //            }
    //        }
    //        .get()
    //    }
    //
    //    func upload<T: AsyncSequence & Sendable>(
    //        sequence: T,
    //        size: UInt,
    //        key: String,
    //        checksum: String?,
    //        timeout: TimeAmount
    //    ) async throws where T.Element == ByteBuffer {
    //        let sourceUrl = basePath.appendingPathComponent(key)
    //        FileManager.default.createFile(atPath: sourceUrl.path, contents: nil)
    //        guard let handle = FileHandle(forWritingAtPath: sourceUrl.path) else {
    //            throw StorageServiceError.invalidKey
    //        }
    //
    //        var calculator: ChecksumCalculator?
    //        if checksum != nil {
    //            calculator = createChecksumCalculator()
    //        }
    //        for try await buffer in sequence {
    //            handle.write(.init(buffer: buffer))
    //            var buff = buffer
    //            let bytes = buff.readBytes(length: buff.readableBytes) ?? []
    //            calculator?.update(bytes)
    //        }
    //
    //        if let checksum, let calculator, checksum != calculator.finalize() {
    //            throw StorageServiceError.invalidChecksum
    //        }
    //
    //        try handle.close()
    //    }
    //
    //    func create(
    //        key: String
    //    ) async throws {
    //        let dirUrl = basePath.appendingPathComponent(key)
    //        try createDir(at: dirUrl)
    //    }
    //
    //
    //    func list(
    //        key: String?
    //    ) async throws -> [String] {
    //        let dirUrl = basePath.appendingPathComponent(key ?? "")
    //        var isDir: ObjCBool = false
    //        if FileManager.default.fileExists(atPath: dirUrl.path, isDirectory: &isDir), isDir.boolValue {
    //            let files = try FileManager.default.contentsOfDirectory(atPath: dirUrl.path)
    //            return files
    //        }
    //        /// it was a file... files don't have children, so we return an empty array.
    //        return []
    //    }
    //
    //    func copy(
    //        key source: String,
    //        to destination: String
    //    ) async throws {
    //        let exists = await exists(key: source)
    //        guard exists else {
    //            throw StorageServiceError.invalidKey
    //        }
    //        try await delete(key: destination)
    //        let sourceUrl = basePath.appendingPathComponent(source)
    //        let destinationUrl = basePath.appendingPathComponent(destination)
    //        let location = destinationUrl.deletingLastPathComponent()
    //        try createDir(at: location)
    //        try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
    //    }
    //
    //    func move(
    //        key source: String,
    //        to destination: String
    //    ) async throws {
    //        try await copy(key: source, to: destination)
    //        try await delete(key: source)
    //    }
    //
    //    func delete(
    //        key: String
    //    ) async throws {
    //        let exists = await exists(key: key)
    //        guard exists else {
    //            return
    //        }
    //        let fileUrl = basePath.appendingPathComponent(key)
    //        try FileManager.default.removeItem(atPath: fileUrl.path)
    //    }
    //
    //    func exists(key: String) async -> Bool {
    //        let fileUrl = basePath.appendingPathComponent(key)
    //        return FileManager.default.fileExists(atPath: fileUrl.path)
    //    }
    //
    //    func createMultipartUpload(
    //        key: String
    //    ) async throws -> MultipartUpload.ID {
    //        let uploadId = MultipartUpload.ID(UUID().uuidString)
    //        let multipartDirKey = key + "+multipart/" + uploadId.value
    //        try await create(key: multipartDirKey)
    //        return uploadId
    //    }
    //
    //    func uploadMultipartChunk(
    //        key: String,
    //        buffer: ByteBuffer,
    //        uploadId: MultipartUpload.ID,
    //        partNumber: Int,
    //        timeout: TimeAmount
    //    ) async throws -> MultipartUpload.Chunk {
    //        let multipartDirKey = key + "+multipart/" + uploadId.value
    //        let fileId = UUID().uuidString
    //        let fileKey = multipartDirKey + "/" + fileId + "-" + String(partNumber)
    //        try await upload(
    //            key: fileKey,
    //            buffer: buffer,
    //            checksum: nil,
    //            timeout: timeout
    //        )
    //        return .init(id: fileId, number: partNumber)
    //    }
    //
    //    func uploadMultipartChunk<T: AsyncSequence & Sendable>(
    //        key: String,
    //        sequence: T,
    //        size: UInt,
    //        uploadId: MultipartUpload.ID,
    //        partNumber: Int,
    //        timeout: TimeAmount
    //    ) async throws -> MultipartUpload.Chunk where T.Element == ByteBuffer {
    //        let multipartDirKey = key + "+multipart/" + uploadId.value
    //        let fileId = UUID().uuidString
    //        let fileKey = multipartDirKey + "/" + fileId + "-" + String(partNumber)
    //
    //        let sourceUrl = basePath.appendingPathComponent(fileKey)
    //
    //        FileManager.default.createFile(atPath: sourceUrl.path, contents: nil)
    //        guard let handle = FileHandle(forWritingAtPath: sourceUrl.path) else {
    //            throw StorageServiceError.invalidKey
    //        }
    //
    //        for try await buffer in sequence {
    //            handle.write(.init(buffer: buffer))
    //        }
    //        try handle.close()
    //
    //        return .init(id: fileId, number: partNumber)
    //    }
    //
    //    func cancelMultipartUpload(
    //        key: String,
    //        uploadId: MultipartUpload.ID
    //    ) async throws {
    //        let multipartBaseKey = key + "+multipart/"
    //        try await delete(key: multipartBaseKey)
    //    }
    //
    //    func completeMultipartUpload(
    //        key: String,
    //        uploadId: MultipartUpload.ID,
    //        checksum: String?,
    //        chunks: [MultipartUpload.Chunk],
    //        timeout: TimeAmount
    //    ) async throws {
    //        let multipartBaseKey = key + "+multipart/"
    //        let multipartDirKey = multipartBaseKey + uploadId.value
    //
    //        let outputUrl = basePath.appendingPathComponent(key)
    //        FileManager.default.createFile(atPath: outputUrl.path, contents: nil)
    //        guard let writeHandle = FileHandle(forWritingAtPath: outputUrl.path) else {
    //            throw StorageServiceError.invalidKey
    //        }
    //
    //        var calculator: ChecksumCalculator?
    //        if checksum != nil {
    //            calculator = createChecksumCalculator()
    //        }
    //        for chunk in chunks {
    //            let chunkKey = multipartDirKey + "/" + chunk.id + "-" + String(chunk.number)
    //            let chunkUrl = basePath.appendingPathComponent(chunkKey)
    //
    //            guard let readHandle = FileHandle(forReadingAtPath: chunkUrl.path) else {
    //                throw StorageServiceError.invalidKey
    //            }
    //            let attr = try FileManager.default.attributesOfItem(atPath: chunkUrl.path)
    //            let fileSize = attr[FileAttributeKey.size] as! UInt64
    //            let data = readHandle.readData(ofLength: Int(fileSize))
    //            writeHandle.write(data)
    //            try readHandle.close()
    //
    //            calculator?.update([UInt8](data))
    //        }
    //        try writeHandle.close()
    //
    //        if let checksum, let calculator, checksum != calculator.finalize() {
    //            throw StorageServiceError.invalidChecksum
    //        }
    //
    //        try await delete(key: multipartBaseKey)
    //    }
}
