// PositionalTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

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
