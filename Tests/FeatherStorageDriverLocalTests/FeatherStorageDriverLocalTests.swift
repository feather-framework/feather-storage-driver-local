//
//  FeatherStorageDriverLocalTests.swift
//  FeatherStorageDriverLocalTests
//
//  Created by Tibor Bödecs on 2023. 01. 16..
//

import FeatherComponent
import FeatherStorage
import FeatherStorageDriverLocal
import Foundation
import Logging
import NIO
import XCTFeatherStorage
import XCTest

final class FeatherStorageDriverLocalTests: XCTestCase {

    func _testList(_ storage: StorageComponent) async throws {
        let key1 = "dir02/dir03"
        try await storage.create(key: key1)

        let key2 = "dir02/test-01.txt"
        let data = Data("test".utf8)
        try await storage.upload(
            key: key2,
            buffer: .init(data: data)
        )

        let res = try await storage.list(key: "dir02")
        guard res.contains("dir03"), res.contains("test-01.txt") else {
            fatalError()
        }
    }
    
    func testLocalDriverUsingTestSuite() async throws {

        let threadPool = NIOThreadPool(numberOfThreads: 1)
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        threadPool.start()

        do {
            let workUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)

            let registry = ComponentRegistry()
            try await registry.addStorage(
                LocalStorageComponentContext(
                    threadPool: threadPool,
                    eventLoopGroup: eventLoopGroup,
                    path: workUrl.absoluteString
                )
            )

            let storage = try await registry.storage()
            let suite = StorageTestSuite(storage)
            try await _testList(storage)
            try await suite.testAll()
        }
        catch {
            XCTFail("\(error)")
        }

        try await eventLoopGroup.shutdownGracefully()
        try await threadPool.shutdownGracefully()
    }

}
