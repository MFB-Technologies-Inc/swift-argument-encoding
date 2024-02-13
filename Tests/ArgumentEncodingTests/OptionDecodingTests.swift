// OptionDecodingTests.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Foundation
import XCTest

final class OptionDecodingTests: XCTestCase {
    let encoder = JSONEncoder()

    func testDecodeOption() throws {
        let option = Option(wrappedValue: "value")
        let data = try encoder.encode(option)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionConfiguration(for: String.self)
        let decoded = try decoder.decode(Option<String>.self, from: data)
        XCTAssertEqual(decoded, option)
    }

    func testDecodeOptionContainer() throws {
        let container = OptionContainer(option: "value")
        let data = try encoder.encode(container)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionConfiguration(for: String.self)
        let decoded = try decoder.decode(OptionContainer.self, from: data)
        XCTAssertEqual(decoded, container)
    }
}

private struct OptionContainer: ArgumentGroup, Codable, Equatable {
    @Option var option: String

    init(option: String) {
        _option = Option(wrappedValue: option)
    }
}
