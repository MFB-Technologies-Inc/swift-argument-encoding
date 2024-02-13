// OptionSetDecodingTests.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Foundation
import XCTest

final class OptionSetDecodingTests: XCTestCase {
    let encoder = JSONEncoder()

    func testDecodeOptionSet() throws {
        let optionSet = OptionSet(wrappedValue: ["value1", "value2"])
        let data = try encoder.encode(optionSet)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionSetConfiguration(for: [String].self)
        let decoded = try decoder.decode(OptionSet<[String]>.self, from: data)
        XCTAssertEqual(decoded, optionSet)
    }

    func testDecodeOptionSetContainer() throws {
        let container = OptionSetContainer(option: ["value1", "value2"])
        let data = try encoder.encode(container)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionSetConfiguration(for: [String].self)
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
