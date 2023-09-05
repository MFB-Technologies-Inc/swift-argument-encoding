// ArgumentGroupTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding
import Dependencies
import XCTest

final class ArgumentGroupTests: XCTestCase {
    private struct EmptyGroup: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)
    }

    func testEmptyGroup() throws {
        XCTAssertEqual(EmptyGroup().arguments(), [])
    }

    private struct Group: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)

        @Flag var asyncMain: Bool
        @Option var numThreads: Int = 0
        @Positional var target: String

        init(asyncMain: Bool, numThreads: Int, target: String) {
            self.asyncMain = asyncMain
            self.numThreads = numThreads
            _target = Positional(value: target)
        }
    }

    func testGroup() throws {
        XCTAssertEqual(
            Group(
                asyncMain: false,
                numThreads: 2,
                target: "target"
            ).arguments(),
            ["--numThreads", "2", "target"]
        )

        XCTAssertEqual(
            Group(
                asyncMain: true,
                numThreads: 0,
                target: "target"
            ).arguments(),
            ["--asyncMain", "--numThreads", "0", "target"]
        )
    }

    private struct ParentGroup: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)

        @Flag var asyncMain: Bool
        @Option var numThreads: Int = 0
        @Positional var target: String
        var child: ChildGroup

        init(asyncMain: Bool, numThreads: Int, target: String, child: ChildGroup) {
            self.asyncMain = asyncMain
            self.numThreads = numThreads
            _target = Positional(value: target)
            self.child = child
        }
    }

    private struct ChildGroup: ArgumentGroup, FormatterNode {
        let flagFormatter: FlagFormatter = .init(prefix: .singleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .singleDash)

        @Option var configuration: Configuration = .arm64
        @Flag var buildTests: Bool
        @Positional var target: String

        init(configuration: Configuration, buildTests: Bool, target: String) {
            self.configuration = configuration
            self.buildTests = buildTests
            _target = Positional(value: target)
        }

        enum Configuration: String, CustomStringConvertible {
            case arm64
            case x86_64

            var description: String { rawValue }
        }
    }

    func testNestedGroup() throws {
        XCTAssertEqual(
            ParentGroup(
                asyncMain: false,
                numThreads: 2,
                target: "target",
                child: ChildGroup(
                    configuration: .arm64,
                    buildTests: false,
                    target: "target"
                )
            ).arguments(),
            ["--numThreads", "2", "target", "-configuration", "arm64", "target"]
        )

        XCTAssertEqual(
            ParentGroup(
                asyncMain: true,
                numThreads: 1,
                target: "target",
                child: ChildGroup(
                    configuration: .x86_64,
                    buildTests: true,
                    target: "target"
                )
            ).arguments(),
            ["--asyncMain", "--numThreads", "1", "target", "-configuration", "x86_64", "-buildTests", "target"]
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
        var flagFormatter: FlagFormatter { FlagFormatter(prefix: .singleDash) }
        var optionFormatter: OptionFormatter { OptionFormatter(prefix: .singleDash) }

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
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)

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
    public var flagFormatter: ArgumentEncoding.FlagFormatter { FlagFormatter(prefix: .doubleDash) }

    public var optionFormatter: ArgumentEncoding.OptionFormatter { OptionFormatter(prefix: .doubleDash) }
}

extension Dictionary: ArgumentGroup, FormatterNode {
    public var flagFormatter: ArgumentEncoding.FlagFormatter { FlagFormatter(prefix: .doubleDash) }

    public var optionFormatter: ArgumentEncoding.OptionFormatter { OptionFormatter(prefix: .doubleDash) }
}
