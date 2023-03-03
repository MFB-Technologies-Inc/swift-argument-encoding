// FlagFormatter.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies
import XCTestDynamicOverlay

/// Formats `Flag`s to match how different executables format arguments
public struct FlagFormatter {
    /// Formats a key string
    public let format: (_ key: String) -> String

    internal func _format(encoding: FlagEncoding) -> String {
        format(encoding.key)
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - _ format: An escaping closure that takes the Flag's key value as input and returns a formatted String
    public init(_ format: @escaping (_ key: String) -> String) {
        self.format = format
    }
}

extension FlagFormatter {
    /// A formatter that prefixes flags with '-'
    public static let singleDashPrefix = FlagFormatter { StaticString.singleDash.description + $0 }

    /// A formatter that prefixes flags with '-' and converts from camelCase to kebab-case
    public static let singleDashPrefixKebabCase = FlagFormatter { input in
        StaticString.singleDash.description + CaseConverter.kebabCase(input)
    }

    /// A formatter that prefixes flags with '-' and converts from camelCase to snake_case
    public static let singleDashPrefixSnakeCase = FlagFormatter { input in
        StaticString.singleDash.description + CaseConverter.snakeCase(input)
    }

    /// A formatter that prefixes flags with '--'
    public static let doubleDashPrefix = FlagFormatter { StaticString.doubleDash.description + $0 }

    /// A formatter that prefixes flags with '--' and converts from camelCase to kebab-case
    public static let doubleDashPrefixKebabCase = FlagFormatter { input in
        StaticString.doubleDash.description + CaseConverter.kebabCase(input)
    }

    /// A formatter that prefixes flags with '--' and converts from camelCase to snake_case
    public static let doubleDashPrefixSnakeCase = FlagFormatter { input in
        StaticString.doubleDash.description + CaseConverter.snakeCase(input)
    }
}

extension FlagFormatter: TestDependencyKey {
    public static let testValue: FlagFormatter = .unimplemented
}

extension DependencyValues {
    public var flagFormatter: FlagFormatter {
        get { self[FlagFormatter.self] }
        set { self[FlagFormatter.self] = newValue }
    }
}

extension FlagFormatter {
    public static let unimplemented = FlagFormatter(XCTestDynamicOverlay.unimplemented(placeholder: "unimplemented"))
}
