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
            values.optionFormatter = .doubleDashPrefix
        } operation: {
            option.arguments()
        }
        XCTAssertEqual(args, ["--configuration", "release"])
    }
}
