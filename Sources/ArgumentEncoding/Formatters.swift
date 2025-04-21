// Formatters.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import Dependencies
import XCTestDynamicOverlay

/// Formats `Flag`s to match how different executables format arguments
public struct FlagFormatter: Sendable {
    /// Formats a key string
    public let prefix: @Sendable () -> String
    public let key: @Sendable (_ key: String) -> String

    @Sendable
    public func format(key: String) -> String {
        prefix() + self.key(key)
    }

    @Sendable
    func _format(encoding: FlagEncoding) -> String {
        format(key: encoding.key)
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Closure that returns the prefix string
    ///   - key: Closure that transforms the key string for formatting
    public init(
        prefix: @escaping @Sendable () -> String,
        key: @escaping @Sendable (_ key: String) -> String
    ) {
        self.prefix = prefix
        self.key = key
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Name spaced closure that returns the prefix string for a Flag
    ///   - key: Name spaced closure that transforms the key string for formatting
    public init(prefix: PrefixFormatter = .empty, key: KeyFormatter = .empty) {
        self.init(
            prefix: prefix.transform,
            key: key.transform
        )
    }
}

/// Formats `Option`s to match how different executables format arguments
public struct OptionFormatter: Sendable {
    public let prefix: @Sendable () -> String
    public let key: @Sendable (_ key: String) -> String
    public let separator: @Sendable (_ key: String, _ value: String) -> [String]
    public let value: @Sendable (_ value: String) -> String

    public func format(key: String, value: String) -> [String] {
        separator(prefix() + self.key(key), self.value(value))
    }

    func format(encoding: OptionEncoding) -> [String] {
        format(key: encoding.key, value: encoding.value)
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Closure that returns the prefix string
    ///   - key: Closure that transforms the key string for formatting
    ///   - separator: Closure that returns the string that separates the key and value
    ///   - value: Closure that transforms the value string for formatting
    public init(
        prefix: @escaping @Sendable () -> String,
        key: @escaping @Sendable (_ key: String) -> String,
        separator: @escaping @Sendable (_ key: String, _ value: String) -> [String],
        value: @escaping @Sendable (_ value: String) -> String
    ) {
        self.prefix = prefix
        self.key = key
        self.separator = separator
        self.value = value
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Name spaced closure that returns the prefix string for a Flag
    ///   - key: Name spaced closure that transforms the key string for formatting
    ///   - separator: Name spaced closure that returns the string that separates the key and value
    ///   - value: Name spaced closure that transforms the value string for formatting
    public init(
        prefix: PrefixFormatter = .empty,
        key: KeyFormatter = .empty,
        separator: SeparatorFormatter = .separate,
        value: KeyFormatter = .empty
    ) {
        self.init(
            prefix: prefix.transform,
            key: key.transform,
            separator: separator.transform,
            value: value.transform
        )
    }
}

// MARK: Supporting formatters

/// Name space for a closure that returns a string that prefixes a Flag or Option's key
public struct PrefixFormatter: Sendable {
    public let transform: @Sendable () -> String

    public init(_ transform: @escaping @Sendable () -> String) {
        self.transform = transform
    }

    public static let empty = Self { "" }
    public static let singleDash = Self { StaticString.singleDash.description }
    public static let doubleDash = Self { StaticString.doubleDash.description }
}

/// Name space for a closure that transforms a Flag or Option's key
public struct KeyFormatter: Sendable {
    public let transform: @Sendable (_ key: String) -> String

    public init(_ transform: @escaping @Sendable (_ key: String) -> String) {
        self.transform = transform
    }

    public static let empty = Self { $0 }
    public static let kebabCase = Self(CaseConverter.kebabCase)
    public static let snakeCase = Self(CaseConverter.snakeCase)
    public static let singleQuote = Self { "'\($0)'" }
}

/// Name space for a closure that returns the Option's key and value separated by a string or as separate elements in an
/// array
public struct SeparatorFormatter: Sendable {
    public let transform: @Sendable (_ key: String, _ value: String) -> [String]

    public init(_ transform: @escaping @Sendable (_ key: String, _ value: String) -> [String]) {
        self.transform = transform
    }

    public static let separate = Self { [$0, $1] }
    public static let equal = Self { ["\($0)\(StaticString.equal.description)\($1)"] }
}

// MARK: Dependency

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
    public static let unimplemented: FlagFormatter = XCTestDynamicOverlay.unimplemented(placeholder: FlagFormatter())
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
    public static let unimplemented: OptionFormatter = XCTestDynamicOverlay
        .unimplemented(placeholder: OptionFormatter())
}
