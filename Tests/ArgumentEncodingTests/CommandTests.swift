// CommandTests.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import XCTest

final class CommandTests: XCTestCase {
    func testEmptyCommand() throws {
        let command = Command(rawValue: "")
        let args = command.arguments()
        XCTAssertEqual(args, [])
    }

    func testCommand() throws {
        let command = Command(rawValue: "swift")
        let args = command.arguments()
        XCTAssertEqual(args, ["swift"])
    }
}
