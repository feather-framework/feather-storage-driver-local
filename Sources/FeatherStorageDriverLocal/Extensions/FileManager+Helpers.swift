//
//  FileManager+Helpers.swift
//  FeatherStorageDriverLocal
//
//  Created by Tibor Bödecs on 2020. 04. 28..
//

import Foundation

extension FileManager {

    func directoryExists(
        at url: URL
    ) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }

    func fileExists(
        at url: URL
    ) -> Bool {
        var isDirectory = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return !isDirectory.boolValue
        }
        return false
    }

    func createDirectory(
        at url: URL,
        permission: mode_t
    ) throws {
        guard !directoryExists(at: url) else {
            return
        }
        try createDirectory(
            atPath: url.path,
            withIntermediateDirectories: true,
            attributes: [
                .posixPermissions: permission
            ]
        )
    }

    func attributes(at url: URL) throws -> [FileAttributeKey: Any] {
        try attributesOfItem(atPath: url.path)
    }

    func size(at url: URL) throws -> UInt64 {
        if fileExists(at: url) {
            let attributes = try attributes(at: url)
            let size = attributes[.size] as! NSNumber
            return size.uint64Value
        }
        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]
        guard
            let enumerator = enumerator(
                at: url,
                includingPropertiesForKeys: Array(keys)
            )
        else {
            return 0
        }

        var size: UInt64 = 0
        for item in enumerator.compactMap({ $0 as? URL }) {
            let values = try item.resourceValues(forKeys: keys)
            guard values.isRegularFile ?? false else {
                continue
            }
            size += UInt64(
                values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0
            )
        }
        return size
    }
}
