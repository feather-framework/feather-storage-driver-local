//
//  FeatherStorageDriverLocalTests.swift
//  FeatherStorageDriverLocalTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import NIO
import Logging
import Foundation
import XCTest
import FeatherService
import FeatherStorage
import FeatherStorageDriverLocal
import XCTFeatherStorage

final class FeatherStorageDriverLocalTests: XCTestCase {

    func testLocalDriverUsingTestSuite() async throws {

        let threadPool = NIOThreadPool(numberOfThreads: 1)
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        threadPool.start()

        do {
            let workUrl = URL(
                fileURLWithPath: NSTemporaryDirectory()
            )
            .appendingPathComponent(UUID().uuidString)

            let registry = ServiceRegistry()
            try await registry.add(
                .localStorage(
                    threadPool: threadPool,
                    eventLoopGroup: eventLoopGroup,
                    path: workUrl.absoluteString
                ),
                as: .localStorage
            )

            try await registry.run()

            let storage =
                try await registry.get(.localStorage) as! StorageService
            let suite = StorageTestSuite(storage)
            do {
                try await suite.testAll()
                try await registry.shutdown()
            }
            catch {
                try await registry.shutdown()
                throw error
            }
        }
        catch {
            XCTFail("\(error)")
        }

        try await eventLoopGroup.shutdownGracefully()
        try await threadPool.shutdownGracefully()
    }

}
