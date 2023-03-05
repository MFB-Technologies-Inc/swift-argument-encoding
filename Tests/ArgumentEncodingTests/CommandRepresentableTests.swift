// CommandRepresentableTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding
import XCTest

final class CommandRepresentableTests: XCTestCase {
    private struct Container<T>: ArgumentGroup where T: CommandRepresentable {
        static var flagFormatter: FlagFormatter { .doubleDashPrefix }
        static var optionFormatter: OptionFormatter { .doubleDashPrefix }

        var command: T

        init(_ command: T) {
            self.command = command
        }
    }

    private struct EmptyCommand: CommandRepresentable {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix
    }

    func testEmptyCommand() throws {
        let command = Container(EmptyCommand())
        let args = command.arguments()
        XCTAssertEqual(args, ["command"])
    }

    private struct CommandGroup: CommandRepresentable {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix

        @Flag var verbose: Bool
        @Option var product: String? = nil

        init(verbose: Bool, product: String?) {
            self.verbose = verbose
            self.product = product
        }
    }

    func testCommand() throws {
        XCTAssertEqual(
            Container(CommandGroup(
                verbose: false,
                product: "Target"
            )).arguments(),
            [
                "command",
                "--product",
                "Target",
            ]
        )

        XCTAssertEqual(
            Container(CommandGroup(
                verbose: true,
                product: nil
            )).arguments(),
            [
                "command",
                "--verbose",
            ]
        )
    }

    private struct ParentCommand: CommandRepresentable {
        let flagFormatter: FlagFormatter = .doubleDashPrefix
        let optionFormatter: OptionFormatter = .doubleDashPrefix

        @Flag var verbose: Bool
        @Option var product: String? = nil
        var child: ChildCommand

        init(verbose: Bool, product: String?, child: ChildCommand) {
            self.verbose = verbose
            self.product = product
            self.child = child
        }
    }

    private struct ChildCommand: CommandRepresentable {
        let flagFormatter: FlagFormatter = .singleDashPrefix
        let optionFormatter: OptionFormatter = .singleDashPrefix

        @Option var configuration: Configuration = .arm64
        @Flag var buildTests: Bool

        init(configuration: Configuration, buildTests: Bool) {
            self.configuration = configuration
            self.buildTests = buildTests
        }

        enum Configuration: String, CustomStringConvertible {
            case arm64
            case x86_64

            var description: String {
                rawValue
            }
        }
    }

    func testNestedCommand() throws {
        XCTAssertEqual(
            Container(ParentCommand(
                verbose: false,
                product: "OtherTarget",
                child: ChildCommand(
                    configuration: .arm64,
                    buildTests: true
                )
            )).arguments(),
            ["command", "--product", "OtherTarget", "child", "-configuration", "arm64", "-buildTests"]
        )

        XCTAssertEqual(
            Container(ParentCommand(
                verbose: true,
                product: nil,
                child: ChildCommand(
                    configuration: .x86_64,
                    buildTests: false
                )
            )).arguments(),
            ["command", "--verbose", "child", "-configuration", "x86_64"]
        )
    }

    private enum ParentEnumCommand: CommandRepresentable {
        var flagFormatter: FlagFormatter { .singleDashPrefix }
        var optionFormatter: OptionFormatter { .singleDashPrefix }

        case run(asyncMain: Flag, skipBuild: Flag)
        case test(numWorkers: Option<Int>, testProduct: Option<String>)
        case child(ChildCommand)
    }

    func testEnumRunTrueFalse() throws {
        XCTAssertEqual(
            ParentEnumCommand.run(asyncMain: true, skipBuild: false).arguments(),
            ["run", "-asyncMain"]
        )
    }

    func testEnumRunFalseTrue() throws {
        XCTAssertEqual(
            ParentEnumCommand.run(asyncMain: false, skipBuild: true).arguments(),
            ["run", "-skipBuild"]
        )
    }

    func testEnumRunTrueTrue() throws {
        XCTAssertEqual(
            ParentEnumCommand.run(asyncMain: true, skipBuild: true).arguments(),
            ["run", "-asyncMain", "-skipBuild"]
        )
    }

    func testEnumTest() throws {
        XCTAssertEqual(
            ParentEnumCommand.test(numWorkers: 2, testProduct: "PackageTarget").arguments(),
            ["test", "-numWorkers", "2", "-testProduct", "PackageTarget"]
        )
    }

    func testEnumChild() throws {
        XCTAssertEqual(
            ParentEnumCommand.child(ChildCommand(configuration: .arm64, buildTests: true)).arguments(),
            ["child", "-configuration", "arm64", "-buildTests"]
        )
    }
}
