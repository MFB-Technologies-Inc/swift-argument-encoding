// OptionTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

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
