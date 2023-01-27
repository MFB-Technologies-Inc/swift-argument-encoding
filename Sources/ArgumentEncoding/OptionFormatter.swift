// OptionFormatter.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies
import XCTestDynamicOverlay

/// Formats `Option`s to match how different executables format arguments
public struct OptionFormatter {
    private let format: (Option) -> [String]

    @inline(__always)
    public func strings(_ option: Option) -> [String] {
        format(option)
    }

    public init(_ format: @escaping (Option) -> [String]) {
        self.format = format
    }
}

extension OptionFormatter {
    public static let singleDashPrefix = OptionFormatter { [StaticString.singleDash.description + $0.key, $0.value] }

    public static let doubleDashPrefix = OptionFormatter { [StaticString.doubleDash.description + $0.key, $0.value] }

    public static let equalSeparator = OptionFormatter { [$0.key + StaticString.equal.description + $0.value] }
}

extension OptionFormatter: TestDependencyKey {
    public static let testValue: OptionFormatter = .unimplemented
}

extension DependencyValues {
    public var optionFormatter: OptionFormatter {
        get { self[OptionFormatter.self] }
        set { self[OptionFormatter.self] = newValue }
    }
}

extension OptionFormatter {
    public static let unimplemented = OptionFormatter(XCTestDynamicOverlay.unimplemented())
}
