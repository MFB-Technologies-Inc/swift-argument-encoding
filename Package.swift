// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-argument-encoding",
    platforms: [.macOS(.v12)],
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

package.targets.strictConcurrency()

extension [Target] {
    func strictConcurrency() {
        forEach { target in
            target.swiftSettings = (target.swiftSettings ?? [])
                + [.enableUpcomingFeature("StrictConcurrency")]
        }
    }
}

// MARK: PointFree

extension Package.Dependency {
    static let dependencies: Package.Dependency = .package(
        url: "https://github.com/pointfreeco/swift-dependencies.git",
        .upToNextMajor(from: "1.0.0")
    )
}

extension Target.Dependency {
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
}
