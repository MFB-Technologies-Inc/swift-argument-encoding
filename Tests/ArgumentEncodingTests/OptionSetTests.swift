// OptionSetTests.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Dependencies
import XCTest

final class OptionSetTests: XCTestCase {
    func testOptionSet() throws {
        let optionSet = OptionSet(key: "configuration", value: ["release", "debug"])
        let args = withDependencies { values in
            values.optionFormatter = OptionFormatter(prefix: .doubleDash)
        } operation: {
            optionSet.arguments()
        }
        XCTAssertEqual(args, ["--configuration release", "--configuration debug"])
    }

    func testBothRawValueAndStringConvertible() throws {
        let optionSet = OptionSet(
            key: "configuration",
            value: [
                RawValueCustomStringConvertible(rawValue: "release"),
                RawValueCustomStringConvertible(rawValue: "debug"),
            ]
        )
        let args = withDependencies { values in
            values.optionFormatter = OptionFormatter(prefix: .doubleDash)
        } operation: {
            optionSet.arguments()
        }
        XCTAssertEqual(args, ["--configuration release", "--configuration debug"])
    }

    func testBothRawValueAndStringConvertibleContainer() throws {
        let container = Container(configuration: [
            RawValueCustomStringConvertible(rawValue: "release"),
            RawValueCustomStringConvertible(rawValue: "debug"),
        ])
        let args = withDependencies { values in
            values.optionFormatter = OptionFormatter(prefix: .doubleDash)
        } operation: {
            container.arguments()
        }
        XCTAssertEqual(args, ["--configuration release", "--configuration debug"])
    }
}

private struct RawValueCustomStringConvertible: RawRepresentable, CustomStringConvertible {
    var rawValue: String

    var description: String {
        "description=" + rawValue
    }
}

private struct Container: ArgumentGroup {
    @OptionSet var configuration: [RawValueCustomStringConvertible]

    init(configuration: [RawValueCustomStringConvertible]) {
        _configuration = OptionSet(wrappedValue: configuration)
    }
}
