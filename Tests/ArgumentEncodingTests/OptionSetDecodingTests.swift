// OptionSetDecodingTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding
import Foundation
import XCTest

final class OptionSetDecodingTests: XCTestCase {
    let encoder = JSONEncoder()

    func testDecodeOptionSet() throws {
        let optionSet = OptionSet(wrappedValue: ["value1", "value2"])
        let data = try encoder.encode(optionSet)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionSetConfiguration(for: OptionSet<[String]>.self)
        let decoded = try decoder.decode(OptionSet<[String]>.self, from: data)
        XCTAssertEqual(decoded, optionSet)
    }

    func testDecodeOptionSetContainer() throws {
        let container = OptionSetContainer(option: ["value1", "value2"])
        let data = try encoder.encode(container)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionSetConfiguration(for: OptionSet<[String]>.self)
        let decoded = try decoder.decode(OptionSetContainer.self, from: data)
        XCTAssertEqual(decoded, container)
    }
}

private struct OptionSetContainer: ArgumentGroup, Codable, Equatable {
    @OptionSet var option: [String]

    init(option: [String]) {
        _option = OptionSet(wrappedValue: option)
    }
}
