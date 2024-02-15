// FormatterTests.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Foundation
import XCTest

final class FormatterTests: XCTestCase {
    func testFlagFormatterSingleDashPrefix() throws {
        XCTAssertEqual(
            FlagFormatter(prefix: .singleDash).format(key: "flagKey"),
            "-flagKey"
        )
    }

    func testFlagFormatterDoubleDashPrefix() throws {
        XCTAssertEqual(
            FlagFormatter(prefix: .doubleDash).format(key: "flagKey"),
            "--flagKey"
        )
    }

    func testFlagFormatterEmptyPrefix() throws {
        XCTAssertEqual(
            FlagFormatter(prefix: .empty).format(key: "flagKey"),
            "flagKey"
        )
    }

    func testFlagFormatterKebabCaseBody() throws {
        XCTAssertEqual(
            FlagFormatter(key: .kebabCase).format(key: "flagKey"),
            "flag-key"
        )
    }

    func testFlagFormatterSnakeCaseBody() throws {
        XCTAssertEqual(
            FlagFormatter(key: .snakeCase).format(key: "flagKey"),
            "flag_key"
        )
    }

    func testOptionFormatterSingleDashPrefix() throws {
        XCTAssertEqual(
            OptionFormatter(prefix: .singleDash).format(key: "optionKey", value: "optionValue"),
            ["-optionKey", "optionValue"]
        )
    }

    func testOptionFormatterDoubleDashPrefix() throws {
        XCTAssertEqual(
            OptionFormatter(prefix: .doubleDash).format(key: "optionKey", value: "optionValue"),
            ["--optionKey", "optionValue"]
        )
    }

    func testOptionFormatterEmptyPrefix() throws {
        XCTAssertEqual(
            OptionFormatter(prefix: .empty).format(key: "optionKey", value: "optionValue"),
            ["optionKey", "optionValue"]
        )
    }

    func testOptionFormatterKebabCaseBody() throws {
        XCTAssertEqual(
            OptionFormatter(key: .kebabCase).format(key: "optionKey", value: "optionValue"),
            ["option-key", "optionValue"]
        )
    }

    func testOptionFormatterSnakeCaseBody() throws {
        XCTAssertEqual(
            OptionFormatter(key: .snakeCase).format(key: "optionKey", value: "optionValue"),
            ["option_key", "optionValue"]
        )
    }

    func testOptionFormatterEqualSeparator() throws {
        XCTAssertEqual(
            OptionFormatter(separator: .equal).format(key: "optionKey", value: "optionValue"),
            ["optionKey=optionValue"]
        )
    }

    func testOptionFormatterSingleQuoteValue() throws {
        XCTAssertEqual(
            OptionFormatter(value: .singleQuote).format(key: "optionKey", value: "optionValue"),
            ["optionKey", "'optionValue'"]
        )
    }
}
