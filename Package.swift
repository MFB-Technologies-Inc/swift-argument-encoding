// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-argument-encoding",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "ArgumentEncoding", targets: ["ArgumentEncoding"]),
    ],
    dependencies: [
        .dependencies,
    ],
    targets: [
        .target(
            name: "ArgumentEncoding",
            dependencies: [
                .dependencies,
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
    static let dependencies: Package.Dependency = .package(
        url: "https://github.com/pointfreeco/swift-dependencies.git",
        .upToNextMajor(from: "0.1.1")
    )
}

extension Target.Dependency {
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
}
