// TopLevelCommandRepresentableTests.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import XCTest

final class TopLevelCommandRepresentableTests: XCTestCase {
    private struct EmptyCommand: TopLevelCommandRepresentable {
        func commandValue() -> Command { "swift" }
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)
    }

    func testEmptyCommand() throws {
        let command = EmptyCommand()
        let args = command.arguments()
        XCTAssertEqual(args, ["swift"])
    }

    private struct CommandGroup: TopLevelCommandRepresentable {
        func commandValue() -> Command { "swift" }
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)

        @Flag var verbose: Bool
        @Option var product: String? = nil

        init(verbose: Bool, product: String?) {
            self.verbose = verbose
            self.product = product
        }
    }

    func testCommand() throws {
        XCTAssertEqual(
            CommandGroup(
                verbose: false,
                product: "Target"
            ).arguments(),
            [
                "swift",
                "--product Target",
            ]
        )

        XCTAssertEqual(
            CommandGroup(
                verbose: true,
                product: nil
            ).arguments(),
            [
                "swift",
                "--verbose",
            ]
        )
    }

    private struct ParentCommand: TopLevelCommandRepresentable {
        func commandValue() -> Command { "parent" }
        let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)

        @Flag var verbose: Bool
        @Option var product: String? = nil
        var child: ChildCommand

        init(verbose: Bool, product: String?, child: ChildCommand) {
            self.verbose = verbose
            self.product = product
            self.child = child
        }

        struct ChildCommand: CommandRepresentable, FormatterNode {
            func commandValue() -> Command { "child" }
            let flagFormatter: FlagFormatter = .init(prefix: .singleDash)
            let optionFormatter: OptionFormatter = .init(prefix: .singleDash)

            @Option var configuration: Configuration = .arm64
            @Flag var buildTests: Bool

            init(configuration: Configuration, buildTests: Bool) {
                self.configuration = configuration
                self.buildTests = buildTests
            }

            enum Configuration: String, CustomStringConvertible {
                case arm64
                case x86_64

                var description: String { rawValue }
            }
        }
    }

    func testNestedCommand() throws {
        XCTAssertEqual(
            ParentCommand(
                verbose: false,
                product: "OtherTarget",
                child: ParentCommand.ChildCommand(
                    configuration: .arm64,
                    buildTests: true
                )
            ).arguments(),
            ["parent", "--product OtherTarget", "child", "-configuration arm64", "-buildTests"]
        )

        XCTAssertEqual(
            ParentCommand(
                verbose: true,
                product: nil,
                child: ParentCommand.ChildCommand(
                    configuration: .x86_64,
                    buildTests: false
                )
            ).arguments(),
            ["parent", "--verbose", "child", "-configuration x86_64"]
        )
    }

    private enum ParentEnumCommand: TopLevelCommandRepresentable {
        func commandValue() -> Command { "parent" }
        var flagFormatter: FlagFormatter { FlagFormatter(prefix: .singleDash) }
        var optionFormatter: OptionFormatter { OptionFormatter(prefix: .singleDash) }

        case run(asyncMain: Flag, skipBuild: Flag)
        case test(numWorkers: Option<Int>, testProduct: Option<String>)
        case child(ChildEnumCommand)
    }

    private struct ChildEnumCommand: TopLevelCommandRepresentable {
        func commandValue() -> Command { "child" }
        let flagFormatter: FlagFormatter = .init(prefix: .singleDash)
        let optionFormatter: OptionFormatter = .init(prefix: .singleDash)

        @Option var configuration: Configuration = .arm64
        @Flag var buildTests: Bool

        init(configuration: Configuration, buildTests: Bool) {
            self.configuration = configuration
            self.buildTests = buildTests
        }

        enum Configuration: String, CustomStringConvertible {
            case arm64
            case x86_64

            var description: String { rawValue }
        }
    }

    func testEnumRunTrueFalse() throws {
        XCTAssertEqual(
            ParentEnumCommand.run(asyncMain: true, skipBuild: false).arguments(),
            ["parent", "-asyncMain"]
        )
    }

    func testEnumRunFalseTrue() throws {
        XCTAssertEqual(
            ParentEnumCommand.run(asyncMain: false, skipBuild: true).arguments(),
            ["parent", "-skipBuild"]
        )
    }

    func testEnumRunTrueTrue() throws {
        XCTAssertEqual(
            ParentEnumCommand.run(asyncMain: true, skipBuild: true).arguments(),
            ["parent", "-asyncMain", "-skipBuild"]
        )
    }

    func testEnumTest() throws {
        XCTAssertEqual(
            ParentEnumCommand.test(numWorkers: 2, testProduct: "PackageTarget").arguments(),
            ["parent", "-numWorkers 2", "-testProduct PackageTarget"]
        )
    }

    func testEnumChild() throws {
        XCTAssertEqual(
            ParentEnumCommand.child(ChildEnumCommand(configuration: .arm64, buildTests: true)).arguments(),
            ["parent", "child", "-configuration arm64", "-buildTests"]
        )
    }
}
