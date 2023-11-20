# Feather Storage Driver Local

A local file system-based storage driver for the Feather CMS storage service.

## Getting started

⚠️ This repository is a work in progress, things can break until it reaches v1.0.0. 

Use at your own risk.

### Adding the dependency

To add a dependency on the package, declare it in your `Package.swift`:

```swift
.package(url: "https://github.com/feather-framework/feather-storage-driver-local", .upToNextMinor(from: "0.2.0")),
```

and to your application target, add `FeatherStorageDriverLocal` to your dependencies:

```swift
.product(name: "FeatherStorageDriverLocal", package: "feather-storage-driver-local")
```

Example `Package.swift` file with `FeatherStorageDriverLocal` as a dependency:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "my-application",
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-storage-driver-local", .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(name: "MyApplication", dependencies: [
            .product(name: "FeatherStorageDriverLocal", package: "feather-storage-driver-local")
        ]),
        .testTarget(name: "MyApplicationTests", dependencies: [
            .target(name: "MyApplication"),
        ]),
    ]
)
```

