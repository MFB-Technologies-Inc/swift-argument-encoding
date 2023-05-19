// OptionSet.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies
import Foundation

/// A sequence of key/value pair arguments that provides a given value for a option set or variable.
///
/// If an option set is not contained within an ``ArgumentGroup`` it needs an explicit `key` value. The explicit `key`
/// value
/// may be provided when initialized or when calling `arguments(key: String? = nil) -> [String]`.
///
/// ```swift
/// let standaloneOptionSet = OptionSet("name", value: ["value1", "value2])
///
/// standAloneOptionSet.arguments() == ["--name", "value1", "--name", "value2"]
/// ```
///
/// Usually, an option set should be contained within a ``ArgumentGroup`` conforming type that will provide a `key`
/// value.
///
/// ```swift
/// struct Container: ArgumentGroup, FormatterNode {
///     let flagFormatter: FlagFormatter = .doubleDashPrefix
///     let optionFormatter: OptionSetFormatter = .doubleDashPrefix
///
///     @OptionSet var name: String = ["value1", "value2"]
/// }
///
/// OptionSetContainer().arguments() == ["--name", "value1", "--name", "value2"]
/// ```
@propertyWrapper
public struct OptionSet<Value>: OptionSetProtocol where Value: Sequence {
    /// Explicitly specify the key value
    public let keyOverride: String?
    public var wrappedValue: Value

    // Different Value types will encode to arguments differently.
    // Using unwrap, this can be handled individually per type or collectively by protocol
    private let unwrap: @Sendable (Value.Element) -> String?
    internal var unwrapped: [String] {
        wrappedValue.compactMap(unwrap)
    }

    func encoding(key: String? = nil) -> OptionSetEncoding {
        guard let _key = keyOverride ?? key else {
            return OptionSetEncoding(values: [])
        }
        return OptionSetEncoding(values: unwrapped.map { OptionEncoding(key: _key, value: $0) })
    }

    /// Get the OptionSet's argument encoding. If `keyOverRide` and `key` are both `nil`, it will return an empty array.
    ///
    /// - Parameters
    ///     - key: OptionSetally provide a key value.
    /// - Returns: The argument encoding which is an array of strings
    public func arguments(key: String? = nil) -> [String] {
        encoding(key: key).arguments()
    }

    /// Initializes a new option set when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    ///     - unwrap: A closure for mapping a Value to [String]
    public init(
        key: some CustomStringConvertible,
        value: Value,
        unwrap: @escaping @Sendable (Value.Element) -> String?
    ) {
        keyOverride = key.description
        wrappedValue = value
        self.unwrap = unwrap
    }

    /// Initializes a new option set when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ key: OptionSetal explicit key value
    ///     - _ unwrap: A closure for mapping a Value to [String]
    public init(wrappedValue: Value, _ key: String? = nil, _ unwrap: @escaping @Sendable (Value.Element) -> String?) {
        keyOverride = key
        self.wrappedValue = wrappedValue
        self.unwrap = unwrap
    }
}

// MARK: Conditional Conformances

extension OptionSet: Equatable where Value: Equatable {
    public static func == (lhs: OptionSet<Value>, rhs: OptionSet<Value>) -> Bool {
        lhs.keyOverride == rhs.keyOverride
            && lhs.unwrapped == rhs.unwrapped
    }
}

extension OptionSet: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyOverride)
        hasher.combine(unwrapped)
        hasher.combine(ObjectIdentifier(Self.self))
    }
}

extension OptionSet: Sendable where Value: Sendable {}

// MARK: Convenience initializers when Value: CustomStringConvertible

extension OptionSet where Value.Element: CustomStringConvertible {
    /// Initializes a new option set when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init(key: some CustomStringConvertible, value: Value) {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option set when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ key: Optional explicit key value
    public init(wrappedValue: Value, _ key: String? = nil) {
        keyOverride = key
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value.Element) -> String? {
        value.description
    }
}

extension OptionSet where Value.Element: RawRepresentable, Value.Element.RawValue: CustomStringConvertible {
    /// Initializes a new option set when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init(key: some CustomStringConvertible, value: Value) {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option set when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ key: Optional explicit key value
    public init(wrappedValue: Value, _ key: String? = nil) {
        keyOverride = key
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value.Element) -> String? {
        value.rawValue.description
    }
}

extension OptionSet where Value.Element: CustomStringConvertible, Value.Element: RawRepresentable,
    Value.Element.RawValue: CustomStringConvertible
{
    /// Initializes a new option set when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init(key: some CustomStringConvertible, value: Value) {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option set when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ key: Optional explicit key value
    public init(wrappedValue: Value, _ key: String? = nil) {
        keyOverride = key
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value.Element) -> String? {
        value.rawValue.description
    }
}

// MARK: Coding

extension OptionSet: DecodableWithConfiguration where Value: Decodable {
    public init(from decoder: Decoder, configuration: @escaping @Sendable (Value.Element) -> String?) throws {
        let container = try decoder.singleValueContainer()
        try self.init(wrappedValue: container.decode(Value.self), nil, configuration)
    }
}

extension OptionSet: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let configurationCodingUserInfoKey = Self.configurationCodingUserInfoKey(for: Value.Type.self) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No CodingUserInfoKey found for accessing the DecodingConfiguration.",
                underlyingError: nil
            ))
        }
        guard let _configuration = decoder.userInfo[configurationCodingUserInfoKey] else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No DecodingConfiguration found for key: \(configurationCodingUserInfoKey.rawValue)",
                underlyingError: nil
            ))
        }
        guard let configuration = _configuration as? Self.DecodingConfiguration else {
            let desc = "Invalid DecodingConfiguration found for key: \(configurationCodingUserInfoKey.rawValue)"
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: desc,
                underlyingError: nil
            ))
        }
        try self.init(wrappedValue: container.decode(Value.self), nil, configuration)
    }

    public static func configurationCodingUserInfoKey(for _: (some Any).Type) -> CodingUserInfoKey? {
        CodingUserInfoKey(rawValue: ObjectIdentifier(Self.self).debugDescription)
    }
}

extension OptionSet: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: Internal Types

/*
 Dependencies library is used for injecting the formatters. OptionEncoding is
 initialized within a `withDependencies` closure so that the formatter is
 correctly injected.
 */
struct OptionSetEncoding {
    @Dependency(\.optionFormatter) var formatter

    let values: [OptionEncoding]

    func arguments() -> [String] {
        values.map { formatter.format(encoding: $0) }.flatMap { $0 }
    }
}

/*
 Since OptionSet is generic, we need a single type to cast to in ArgumentGroup.
 OptionSetProtocol is that type and OptionSet is the only type that conforms.
 */
protocol OptionSetProtocol {
    func arguments(key: String?) -> [String]
}
