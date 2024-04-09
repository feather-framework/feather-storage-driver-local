// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-storage-driver-local",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatherStorageDriverLocal", targets: ["FeatherStorageDriverLocal"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "2.61.0"),
        .package(url: "https://github.com/feather-framework/feather-storage", .upToNextMinor(from: "0.5.0")),
    ],
    targets: [
        .target(
            name: "FeatherStorageDriverLocal",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "FeatherStorage", package: "feather-storage"),
            ]
        ),
        .testTarget(
            name: "FeatherStorageDriverLocalTests",
            dependencies: [
                .product(name: "FeatherStorage", package: "feather-storage"),
                .product(name: "XCTFeatherStorage", package: "feather-storage"),
                .target(name: "FeatherStorageDriverLocal"),
            ]
        ),
    ]
)
