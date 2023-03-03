// OptionFormatter.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies
import XCTestDynamicOverlay

/// Formats `Option`s to match how different executables format arguments
public struct OptionFormatter {
    private let format: (_ key: String, _ value: String) -> [String]

    internal func format(encoding: OptionEncoding) -> [String] {
        format(encoding.key, encoding.value)
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - _ format: An escaping closure that takes the Option's key and value as input and returns an array of
    /// formatted strings
    public init(_ format: @escaping (_ key: String, _ value: String) -> [String]) {
        self.format = format
    }
}

extension OptionFormatter {
    /// A formatter that prefixes option names with '-'
    public static let singleDashPrefix = OptionFormatter { [StaticString.singleDash.description + $0, $1] }

    /// A formatter that prefixes option names with '-' and converts from camelCase to kebab-case
    public static let singleDashPrefixKebabCase = OptionFormatter { key, value in
        [StaticString.singleDash.description + CaseConverter.kebabCase(key), value]
    }

    /// A formatter that prefixes option names with '-' and converts from camelCase to snake_case
    public static let singleDashPrefixSnakeCase = OptionFormatter { key, value in
        [StaticString.singleDash.description + CaseConverter.snakeCase(key), value]
    }

    /// A formatter that prefixes option names with '--'
    public static let doubleDashPrefix = OptionFormatter { [StaticString.doubleDash.description + $0, $1] }

    /// A formatter that prefixes option names with '--' and converts from camelCase to kebab-case
    public static let doubleDashPrefixKebabCase = OptionFormatter { key, value in
        [StaticString.doubleDash.description + CaseConverter.kebabCase(key), value]
    }

    /// A formatter that prefixes option names with '--' and converts from camelCase to snake_case
    public static let doubleDashPrefixSnakeCase = OptionFormatter { key, value in
        [StaticString.doubleDash.description + CaseConverter.snakeCase(key), value]
    }

    /// A formatter that inserts an '=' between the option name and value
    public static let equalSeparator = OptionFormatter { [$0 + StaticString.equal.description + $1] }

    /// A formatter that inserts an '=' between the option name and value. Also, converts from camelCase to kebab-case
    public static let equalSeparatorKebabCase = OptionFormatter { key, value in
        [CaseConverter.kebabCase(key) + StaticString.equal.description + value]
    }

    /// A formatter that inserts an '=' between the option name and value. Also, converts from camelCase to snake_case
    public static let equalSeparatorSnakeCase = OptionFormatter { key, value in
        [CaseConverter.snakeCase(key) + StaticString.equal.description + value]
    }
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
    public static let unimplemented = OptionFormatter(
        XCTestDynamicOverlay
            .unimplemented(placeholder: ["unimplemented"])
    )
}
