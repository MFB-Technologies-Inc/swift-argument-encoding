// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-argument-encoding",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "ArgumentEncoding", targets: ["ArgumentEncoding"]),
    ],
    dependencies: [
        .dependencies(),
    ],
    targets: [
        .target(
            name: "ArgumentEncoding",
            dependencies: [
                .dependencies(),
            ]
        ),
        .testTarget(
            name: "ArgumentEncodingTests",
            dependencies: [
                "ArgumentEncoding",
            ]
        ),
    ]
)

// MARK: PointFree

extension Package.Dependency {
    static func dependencies() -> Package.Dependency {
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies.git",
            .upToNextMajor(from: "1.0.0")
        )
    }
}

extension Target.Dependency {
    static func dependencies() -> Self {
        .product(name: "Dependencies", package: "swift-dependencies")
    }
}
