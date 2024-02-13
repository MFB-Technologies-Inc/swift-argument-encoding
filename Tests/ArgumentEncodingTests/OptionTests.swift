// OptionTests.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Dependencies
import XCTest

final class OptionTests: XCTestCase {
    func testOption() throws {
        let option = Option(key: "configuration", value: "release")
        let args = withDependencies { values in
            values.optionFormatter = OptionFormatter(prefix: .doubleDash)
        } operation: {
            option.arguments()
        }
        XCTAssertEqual(args, ["--configuration release"])
    }

    func testBothRawValueAndStringConvertible() throws {
        let option = Option(key: "configuration", value: RawValueCustomStringConvertible(rawValue: "release"))
        let args = withDependencies { values in
            values.optionFormatter = OptionFormatter(prefix: .doubleDash)
        } operation: {
            option.arguments()
        }
        XCTAssertEqual(args, ["--configuration release"])
    }

    func testBothRawValueAndStringConvertibleContainer() throws {
        let container = Container(configuration: RawValueCustomStringConvertible(rawValue: "release"))
        let args = withDependencies { values in
            values.optionFormatter = OptionFormatter(prefix: .doubleDash)
        } operation: {
            container.arguments()
        }
        XCTAssertEqual(args, ["--configuration release"])
    }
}

private struct RawValueCustomStringConvertible: RawRepresentable, CustomStringConvertible {
    var rawValue: String

    var description: String {
        "description=" + rawValue
    }
}

private struct Container: ArgumentGroup {
    @Option var configuration: RawValueCustomStringConvertible

    init(configuration: RawValueCustomStringConvertible) {
        _configuration = Option(wrappedValue: configuration)
    }
}
