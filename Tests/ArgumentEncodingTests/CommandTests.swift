// CommandTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

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
