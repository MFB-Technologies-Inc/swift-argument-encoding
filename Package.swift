// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-argument-encoding",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ArgumentEncoding", targets: ["ArgumentEncoding"]),
    ],
    dependencies: [
        .benchmark,
        .dependencies,
    ],
    targets: [
        .target(
            name: "ArgumentEncoding",
            dependencies: [
                .dependencies,
            ],
            swiftSettings: .swiftSix
        ),
        .testTarget(
            name: "ArgumentEncodingTests",
            dependencies: [
                "ArgumentEncoding",
            ],
            swiftSettings: .swiftSix
        ),
        .executableTarget(
            name: "swift-argument-encoding-benchmark",
            dependencies: [
                "ArgumentEncoding",
                .benchmark,
            ],
            path: "Benchmarks/swift-argument-encoding-benchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)

// MARK: Ordo One

extension Package.Dependency {
    static let benchmark: Package.Dependency = .package(
        url: "https://github.com/ordo-one/package-benchmark.git",
        from: "1.22.4"
    )
}

extension Target.Dependency {
    static let benchmark: Self = .product(name: "Benchmark", package: "package-benchmark")
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

extension [SwiftSetting] {
    static let swiftSix: Self = [
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("DeprecateApplicationMain"),
        .enableUpcomingFeature("DisableOutwardActorInference"),
        .enableUpcomingFeature("ForwardTrailingClosures"),
        .enableUpcomingFeature("ImportObjcForwardDeclarations"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("StrictConcurrency"),
    ]
}
