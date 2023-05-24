// OptionDecodingTests.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding
import Foundation
import XCTest

final class OptionDecodingTests: XCTestCase {
    let encoder = JSONEncoder()

    func testDecodeOption() throws {
        let option = Option(wrappedValue: "value")
        let data = try encoder.encode(option)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionConfiguration(for: Option<String>.self)
        let decoded = try decoder.decode(Option<String>.self, from: data)
        XCTAssertEqual(decoded, option)
    }

    func testDecodeOptionContainer() throws {
        let container = OptionContainer(option: "value")
        let data = try encoder.encode(container)
        let decoder = JSONDecoder()
        decoder.userInfo.addOptionConfiguration(for: Option<String>.self)
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
