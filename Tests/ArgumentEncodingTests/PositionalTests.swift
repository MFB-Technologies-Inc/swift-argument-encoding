// PositionalTests.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Dependencies
import XCTest

final class PositionalTests: XCTestCase {
    func testPositional() throws {
        let positional = Positional(value: "positional-argument")
        let args = positional.arguments()
        XCTAssertEqual(args, ["positional-argument"])
    }

    func testBothRawValueAndStringConvertible() throws {
        let positional = Positional(value: RawValueCustomStringConvertible(rawValue: "positional-argument"))
        let args = positional.arguments()
        XCTAssertEqual(args, ["positional-argument"])
    }

    func testBothRawValueAndStringConvertibleContainer() throws {
        let container = Container(configuration: RawValueCustomStringConvertible(rawValue: "positional-argument"))
        let args = container.arguments()
        XCTAssertEqual(args, ["positional-argument"])
    }

    func testPositionalArgumentGroup() throws {
        let positional =
            Positional(
                value: Container(configuration: RawValueCustomStringConvertible(rawValue: "positional-argument"))
            )
        let args = positional.arguments()
        XCTAssertEqual(args, ["positional-argument"])
    }
}

private struct RawValueCustomStringConvertible: RawRepresentable, CustomStringConvertible {
    var rawValue: String

    var description: String {
        "description=" + rawValue
    }
}

private struct Container: ArgumentGroup {
    @Positional var configuration: RawValueCustomStringConvertible

    init(configuration: RawValueCustomStringConvertible) {
        _configuration = Positional(wrappedValue: configuration)
    }
}
