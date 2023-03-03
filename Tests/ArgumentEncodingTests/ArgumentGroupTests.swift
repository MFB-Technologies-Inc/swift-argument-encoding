// ArgumentGroupTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding
import Dependencies
import XCTest

final class ArgumentGroupTests: XCTestCase {
    private struct EmptyGroup: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix
    }

    func testEmptyGroup() throws {
        XCTAssertEqual(EmptyGroup().arguments(), [])
    }

    private struct Group: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix

        @Flag var asyncMain: Bool
        @Option var numThreads: Int = 0

        init(asyncMain: Bool, numThreads: Int) {
            self.asyncMain = asyncMain
            self.numThreads = numThreads
        }
    }

    func testGroup() throws {
        XCTAssertEqual(
            Group(
                asyncMain: false,
                numThreads: 2
            ).arguments(),
            ["--numThreads", "2"]
        )

        XCTAssertEqual(
            Group(
                asyncMain: true,
                numThreads: 0
            ).arguments(),
            ["--asyncMain", "--numThreads", "0"]
        )
    }

    private struct ParentGroup: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix

        @Flag var asyncMain: Bool
        @Option var numThreads: Int = 0
        var child: ChildGroup

        init(asyncMain: Bool, numThreads: Int, child: ChildGroup) {
            self.asyncMain = asyncMain
            self.numThreads = numThreads
            self.child = child
        }
    }

    private struct ChildGroup: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .singleDashPrefix
        let optionFormatter: OptionFormatter = .singleDashPrefix

        @Option var configuration: Configuration = .arm64
        @Flag var buildTests: Bool

        init(configuration: Configuration, buildTests: Bool) {
            self.configuration = configuration
            self.buildTests = buildTests
        }

        enum Configuration: String {
            case arm64
            case x86_64
        }
    }

    func testNestedGroup() throws {
        XCTAssertEqual(
            ParentGroup(
                asyncMain: false,
                numThreads: 2,
                child: ChildGroup(
                    configuration: .arm64,
                    buildTests: false
                )
            ).arguments(),
            ["--numThreads", "2", "-configuration", "arm64"]
        )

        XCTAssertEqual(
            ParentGroup(
                asyncMain: true,
                numThreads: 1,
                child: ChildGroup(
                    configuration: .x86_64,
                    buildTests: true
                )
            ).arguments(),
            ["--asyncMain", "--numThreads", "1", "-configuration", "x86_64", "-buildTests"]
        )
    }

    func testArrayGroup() throws {
        XCTAssertEqual(
            [Flag("asyncMain", enabled: true), Flag("buildTests", enabled: false)].arguments(),
            ["--asyncMain"]
        )

        XCTAssertEqual(
            [Flag("asyncMain", enabled: false), Flag("buildTests", enabled: true)].arguments(),
            ["--buildTests"]
        )

        XCTAssertEqual(
            [Flag("asyncMain", enabled: true), Flag("buildTests", enabled: true)].arguments(),
            ["--asyncMain", "--buildTests"]
        )

        XCTAssertEqual(
            [Flag("asyncMain", enabled: false), Flag("buildTests", enabled: false)].arguments(),
            []
        )

        XCTAssertEqual(
            [Flag(wrappedValue: true)].arguments(),
            []
        )
    }

    func testDictionaryGroup() throws {
        XCTAssertEqual(
            ["asyncMain": Flag(wrappedValue: true), "buildTests": Flag(wrappedValue: false)].arguments(),
            ["--asyncMain"]
        )

        XCTAssertEqual(
            ["asyncMain": Flag(wrappedValue: false), "buildTests": Flag(wrappedValue: true)].arguments(),
            ["--buildTests"]
        )

        XCTAssertEqual(
            ["asyncMain": Flag(wrappedValue: true), "buildTests": Flag(wrappedValue: true)].arguments().sorted(),
            ["--asyncMain", "--buildTests"]
        )

        XCTAssertEqual(
            ["asyncMain": Flag(wrappedValue: false), "buildTests": Flag(wrappedValue: false)].arguments(),
            []
        )
    }

    private enum ParentEnumGroup: ArgumentGroup, FormatterNode {
        var flagFormatter: FlagFormatter { .singleDashPrefix }
        var optionFormatter: OptionFormatter { .singleDashPrefix }

        case run(asyncMain: Flag, skipBuild: Flag)
        case test(numWorkers: Option<Int>, testProduct: Option<String>)
        case child(ChildGroup)
    }

    func testEnumGroupRunAsyncMain() throws {
        XCTAssertEqual(
            ParentEnumGroup.run(asyncMain: true, skipBuild: false).arguments(),
            ["-asyncMain"]
        )
    }

    func testEnumGroupRunSkipBuild() throws {
        XCTAssertEqual(
            ParentEnumGroup.run(asyncMain: false, skipBuild: true).arguments(),
            ["-skipBuild"]
        )
    }

    func testEnumGroupRunAsyncMainAndSkipBuild() throws {
        XCTAssertEqual(
            ParentEnumGroup.run(asyncMain: true, skipBuild: true).arguments(),
            ["-asyncMain", "-skipBuild"]
        )
    }

    func testEnumGroupTest() throws {
        XCTAssertEqual(
            ParentEnumGroup.test(numWorkers: 2, testProduct: "PackageTarget").arguments(),
            ["-numWorkers", "2", "-testProduct", "PackageTarget"]
        )
    }

    private struct DeepNestedA: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix

        @Flag var deepNestedA: Bool = true
        var deepNestedB: DeepNestedB = .init()
    }

    private struct DeepNestedB: ArgumentGroup {
        @Flag var deepNestedB: Bool = true
        var deepNestedC: DeepNestedC = .init()
    }

    private struct DeepNestedC: ArgumentGroup {
        @Flag var deepNestedC: Bool = true
        var deepNestedD: DeepNestedD = .init()
    }

    private struct DeepNestedD: ArgumentGroup {
        @Flag var deepNestedD: Bool = true
        var deepNestedE: DeepNestedE = .init()
    }

    private struct DeepNestedE: ArgumentGroup {
        @Flag var deepNestedE: Bool = true
        var deepNestedF: DeepNestedF = .init()
    }

    private struct DeepNestedF: ArgumentGroup {
        @Flag var deepNestedF: Bool = true
    }

    func testDeepNested() throws {
        XCTAssertEqual(
            DeepNestedA().arguments(),
            ["--deepNestedA", "--deepNestedB", "--deepNestedC", "--deepNestedD", "--deepNestedE", "--deepNestedF"]
        )
    }
}

extension Array: ArgumentGroup, FormatterNode {
    public var flagFormatter: ArgumentEncoding.FlagFormatter { .doubleDashPrefix }

    public var optionFormatter: ArgumentEncoding.OptionFormatter { .doubleDashPrefix }
}

extension Dictionary: ArgumentGroup, FormatterNode {
    public var flagFormatter: ArgumentEncoding.FlagFormatter { .doubleDashPrefix }

    public var optionFormatter: ArgumentEncoding.OptionFormatter { .doubleDashPrefix }
}
