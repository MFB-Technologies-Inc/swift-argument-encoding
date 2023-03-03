// FlagTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding
import Dependencies
import XCTest

final class FlagTests: XCTestCase {
    func testFlagImplicitEnabled() throws {
        let flag = Flag("verbose")
        let args = withDependencies { values in
            values.flagFormatter = .doubleDashPrefix
        } operation: {
            flag.arguments()
        }
        XCTAssertEqual(args, ["--verbose"])
    }

    func testFlagExplicitEnabled() throws {
        let flag = Flag("verbose", enabled: true)
        let args = withDependencies { values in
            values.flagFormatter = .doubleDashPrefix
        } operation: {
            flag.arguments()
        }
        XCTAssertEqual(args, ["--verbose"])
    }
}
