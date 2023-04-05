// Flag.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies

/// Argument type that enables or disables a given feature. Flags never encode with a value like ``Option``.
///
///
/// If a flag is not contained within an ``ArgumentGroup`` it needs an explicit `key` value. The explicit `key` value
/// may be provided when initialized or when calling `arguments(key: String? = nil) -> [String]`.
///
/// ```swift
/// let standAloneFlag = Flag("name", enabled: true)
///
/// standAloneFlag.arguments() == ["--name"]
/// ```
///
/// Usually, a flag should be contained within a ``ArgumentGroup`` conforming type that will provide a `key` value.
///
/// ```swift
/// struct FlagContainer: ArgumentGroup, FormatterNode {
///     let flagFormatter: FlagFormatter = .doubleDashPrefix
///     let optionFormatter: OptionFormatter = .doubleDashPrefix
///
///     @Flag var name: Bool = true
/// }
///
/// FlagContainer().arguments() == ["--name"]
/// ```
@propertyWrapper
public struct Flag: Sendable, Hashable {
    /// Explicitly specify the key value
    public let keyOverride: String?
    public var wrappedValue: Bool

    /// Is the flag enabled or disabled? If disabled, it will be omitted from the arguments output.
    public var enabled: Bool {
        wrappedValue
    }

    func encoding(key: String? = nil) -> FlagEncoding? {
        guard let _key = keyOverride ?? key, enabled else {
            return nil
        }
        return FlagEncoding(key: _key)
    }

    /// Get the Flag's argument encoding. If `enabled == false`or `keyOverRide` and `key` are both `nil`, it will return
    /// an empty array.
    ///
    /// - Parameters
    ///     - key: Optionally provide a key value.
    /// - Returns: The argument encoding which is an array of strings
    public func arguments(key: String? = nil) -> [String] {
        guard enabled, let encoding = encoding(key: key) else {
            return []
        }
        return [encoding.argument()]
    }

    /// Initializes a new flag when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying enabled/disabled value
    ///     - _ key: Optional explicit key value
    public init(wrappedValue: Bool, _ key: String? = nil) {
        keyOverride = key
        self.wrappedValue = wrappedValue
    }

    /// Initializes a new flag when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - _ key: Optional explicit key value
    ///     - enabled: The underlying enabled/disabled value
    public init(_ key: some CustomStringConvertible, enabled: Bool = true) {
        keyOverride = key.description
        wrappedValue = enabled
    }
}

// MARK: ExpressibleByBooleanLiteral conformance

extension Flag: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(wrappedValue: value)
    }
}

// MARK: Decodable Conformance

extension Flag: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(wrappedValue: container.decode(Bool.self))
    }
}

// MARK: Encodable Conformance

extension Flag: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: Internal Types

/*
 Dependencies library is used for injecting the formatters. FlagEncoding is
 initialized within a `withDependencies` closure so that the formatter is
 correctly injected.
 */
struct FlagEncoding {
    @Dependency(\.flagFormatter) var formatter

    let key: String

    func argument() -> String {
        formatter._format(encoding: self)
    }
}
