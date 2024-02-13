// Formatters.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Dependencies
import XCTestDynamicOverlay

/// Formats `Flag`s to match how different executables format arguments
public struct FlagFormatter: Sendable {
    /// Formats a key string
    public let prefix: @Sendable () -> String
    public let body: @Sendable (_ key: String) -> String

    @Sendable
    public func format(key: String) -> String {
        prefix() + body(key)
    }

    @Sendable
    func _format(encoding: FlagEncoding) -> String {
        format(key: encoding.key)
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Closure that returns the prefix string
    ///   - body: Closure that transforms the key string for formatting
    public init(
        prefix: @escaping @Sendable () -> String,
        body: @escaping @Sendable (_ key: String) -> String
    ) {
        self.prefix = prefix
        self.body = body
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Name spaced closure that returns the prefix string for a Flag
    ///   - body: Name spaced closure that transforms the key string for formatting
    public init(prefix: PrefixFormatter = .empty, body: BodyFormatter = .empty) {
        self.init(
            prefix: prefix.transform,
            body: body.transform
        )
    }
}

/// Formats `Option`s to match how different executables format arguments
public struct OptionFormatter: Sendable {
    public let prefix: @Sendable () -> String
    public let body: @Sendable (_ key: String) -> String
    public let separator: @Sendable () -> String

    public func format(key: String, value: String) -> String {
        prefix() + body(key) + separator() + value
    }

    func format(encoding: OptionEncoding) -> String {
        format(key: encoding.key, value: encoding.value)
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Closure that returns the prefix string
    ///   - body: Closure that transforms the key string for formatting
    ///   - separator: Closure that returns the string that separates the key and value
    public init(
        prefix: @escaping @Sendable () -> String,
        body: @escaping @Sendable (_ key: String) -> String,
        separator: @escaping @Sendable () -> String
    ) {
        self.prefix = prefix
        self.body = body
        self.separator = separator
    }

    /// Initialize a new formatter
    ///
    /// - Parameters
    ///   - prefix: Name spaced closure that returns the prefix string for a Flag
    ///   - body: Name spaced closure that transforms the key string for formatting
    ///   - separator: Name spaced closure that returns the string that separates the key and value
    public init(
        prefix: PrefixFormatter = .empty,
        body: BodyFormatter = .empty,
        separator: SeparatorFormatter = .space
    ) {
        self.init(
            prefix: prefix.transform,
            body: body.transform,
            separator: separator.transform
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
public struct BodyFormatter: Sendable {
    public let transform: @Sendable (_ key: String) -> String

    public init(_ transform: @escaping @Sendable (_ key: String) -> String) {
        self.transform = transform
    }

    public static let empty = Self { $0 }
    public static let kebabCase = Self(CaseConverter.kebabCase)
    public static let snakeCase = Self(CaseConverter.snakeCase)
}

/// Name space for a closure that returns the separator string between an Option's key and value
public struct SeparatorFormatter: Sendable {
    public let transform: @Sendable () -> String

    public init(_ transform: @escaping @Sendable () -> String) {
        self.transform = transform
    }

    public static let space = Self { StaticString.space.description }
    public static let equal = Self { StaticString.equal.description }
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
