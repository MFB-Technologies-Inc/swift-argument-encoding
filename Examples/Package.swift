// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-argument-encoding-examples",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "SwiftCommand", targets: ["SwiftCommand"]),
    ],
    dependencies: [
        .argumentEncoding(),
    ],
    targets: [
        .executableTarget(
            name: "SwiftCommand",
            dependencies: [
                .argumentEncoding(),
            ]
        ),
    ]
)

// MARK: Local

extension Package.Dependency {
    static func argumentEncoding() -> Package.Dependency {
        .package(name: "swift-argument-encoding", path: "../")
    }
}

extension Target.Dependency {
    static func argumentEncoding() -> Self {
        .product(name: "ArgumentEncoding", package: "swift-argument-encoding")
    }
}
