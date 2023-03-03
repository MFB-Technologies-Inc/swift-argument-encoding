// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-argument-encoding-examples",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "SwiftCommand", targets: ["SwiftCommand"]),
    ],
    dependencies: [
        .argumentEncoding,
    ],
    targets: [
        .executableTarget(
            name: "SwiftCommand",
            dependencies: [
                .argumentEncoding,
            ]
        ),
    ]
)

// MARK: Local

extension Package.Dependency {
    static let argumentEncoding: Package.Dependency = .package(name: "swift-argument-encoding", path: "../")
}

extension Target.Dependency {
    static let argumentEncoding: Self = .product(name: "ArgumentEncoding", package: "swift-argument-encoding")
}
