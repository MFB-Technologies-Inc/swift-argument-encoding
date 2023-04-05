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

    private struct FlagContainer: Equatable, Codable {
        @Flag var flag: Bool
    }

    private struct BoolContainer: Equatable, Codable {
        var flag: Bool
    }

    func testFlagEncode() throws {
        let encoder = JSONEncoder()

        let flagFalse = Flag("key", enabled: false)
        XCTAssertEqual(try encoder.encode(flagFalse), try encoder.encode(false))

        let flagTrue = Flag("key", enabled: true)
        XCTAssertEqual(try encoder.encode(flagTrue), try encoder.encode(true))

        let containerFalse = FlagContainer(flag: false)
        XCTAssertEqual(try encoder.encode(containerFalse), try encoder.encode(BoolContainer(flag: false)))

        let containerTrue = FlagContainer(flag: true)
        XCTAssertEqual(try encoder.encode(containerTrue), try encoder.encode(BoolContainer(flag: true)))
    }

    func testFlagDecode() throws {
        let decoder = JSONDecoder()

        let encodedTrue = try XCTUnwrap("true".data(using: .utf8))
        let encodedFalse = try XCTUnwrap("false".data(using: .utf8))

        let encodedContainerTrue = try XCTUnwrap("""
        {
            "flag": true
        }
        """.data(using: .utf8))
        let encodedContainerFalse = try XCTUnwrap("""
        {
            "flag": false
        }
        """.data(using: .utf8))

        XCTAssertEqual(try decoder.decode(Flag.self, from: encodedTrue), Flag(wrappedValue: true))
        XCTAssertEqual(try decoder.decode(Flag.self, from: encodedFalse), Flag(wrappedValue: false))

        XCTAssertEqual(try decoder.decode(FlagContainer.self, from: encodedContainerTrue), FlagContainer(flag: true))
        XCTAssertEqual(try decoder.decode(FlagContainer.self, from: encodedContainerFalse), FlagContainer(flag: false))
    }
}
