// Option.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import Dependencies
import Foundation

/// A key/value pair argument that provides a given value for a option or variable.
///
/// If an option is not contained within an ``ArgumentGroup`` it needs an explicit `key` value. The explicit `key` value
/// may be provided when initialized or when calling `arguments(key: String? = nil) -> [String]`.
///
/// ```swift
/// let standaloneOption = Option("name", value: "value")
///
/// standAloneOption.arguments() == ["--name", "value]
/// ```
///
/// Usually, an option should be contained within a ``ArgumentGroup`` conforming type that will provide a `key` value.
///
/// ```swift
/// struct Container: ArgumentGroup, FormatterNode {
///     let flagFormatter: FlagFormatter = .doubleDashPrefix
///     let optionFormatter: OptionFormatter = OptionFormatter(prefix: .doubleDash)
///
///     @Option var name: String = "value"
/// }
///
/// Container().arguments() == ["--name", "value"]
/// ```
@propertyWrapper
public struct Option<Value>: OptionProtocol {
    /// Explicitly specify the key value
    public let keyOverride: String?
    public var wrappedValue: Value

    // Different Value types will encode to arguments differently.
    // Using unwrap, this can be handled individually per type or collectively by protocol
    private let unwrap: @Sendable (Value) -> String?
    var unwrapped: String? {
        unwrap(wrappedValue)
    }

    func encoding(key: String? = nil) -> OptionEncoding? {
        guard let _key = keyOverride ?? key else {
            return nil
        }
        guard let unwrapped else {
            return nil
        }
        return OptionEncoding(key: _key, value: unwrapped)
    }

    /// Get the Option's argument encoding. If `keyOverRide` and `key` are both `nil`, it will return an empty array.
    ///
    /// - Parameters
    ///     - key: Optionally provide a key value.
    /// - Returns: The argument encoding which is an array of strings
    public func arguments(key: String? = nil) -> [String] {
        encoding(key: key)?.arguments() ?? []
    }

    /// Initializes a new option when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    ///     - unwrap: A closure for mapping a Value to [String]
    public init(key: some CustomStringConvertible, value: Value, unwrap: @escaping @Sendable (Value) -> String?) {
        keyOverride = key.description
        wrappedValue = value
        self.unwrap = unwrap
    }

    /// Initializes a new option when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ key: Optional explicit key value
    ///     - _ unwrap: A closure for mapping a Value to [String]
    public init(wrappedValue: Value, _ key: String? = nil, _ unwrap: @escaping @Sendable (Value) -> String?) {
        keyOverride = key
        self.wrappedValue = wrappedValue
        self.unwrap = unwrap
    }
}

// MARK: Conditional Conformances

extension Option: Equatable where Value: Equatable {
    public static func == (lhs: Option<Value>, rhs: Option<Value>) -> Bool {
        lhs.keyOverride == rhs.keyOverride
            && lhs.unwrapped == rhs.unwrapped
    }
}

extension Option: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyOverride)
        hasher.combine(unwrapped)
        hasher.combine(ObjectIdentifier(Self.self))
    }
}

extension Option: Sendable where Value: Sendable {}

// MARK: Convenience initializers when Value: CustomStringConvertible

extension Option where Value: CustomStringConvertible {
    /// Initializes a new option when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init(key: some CustomStringConvertible, value: Value) {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option when used as a `@propertyWrapper`
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
    public static func unwrap(_ value: Value) -> String? {
        value.description
    }
}

extension Option where Value: RawRepresentable, Value.RawValue: CustomStringConvertible {
    /// Initializes a new option when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init(key: some CustomStringConvertible, value: Value) {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option when used as a `@propertyWrapper`
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
    public static func unwrap(_ value: Value) -> String? {
        value.rawValue.description
    }
}

extension Option where Value: CustomStringConvertible, Value: RawRepresentable,
    Value.RawValue: CustomStringConvertible
{
    /// Initializes a new option when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init(key: some CustomStringConvertible, value: Value) {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option when used as a `@propertyWrapper`
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
    public static func unwrap(_ value: Value) -> String? {
        value.rawValue.description
    }
}

// MARK: Convenience initializers when Value == Optional<Wrapped>

extension Option {
    /// Initializes a new option when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - key: Explicit key value
    ///     - wrappedValue: The underlying value
    public init<Wrapped>(key: some CustomStringConvertible, value: Wrapped?) where Wrapped: CustomStringConvertible,
        Value == Wrapped?
    {
        keyOverride = key.description
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new option when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ key: Optional explicit key value
    public init<Wrapped>(wrappedValue: Wrapped?, _ key: String? = nil) where Wrapped: CustomStringConvertible,
        Value == Wrapped?
    {
        keyOverride = key
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap<Wrapped>(_ value: Wrapped?) -> String? where Wrapped: CustomStringConvertible,
        Value == Wrapped?
    {
        value?.description
    }
}

// MARK: ExpressibleBy...Literal conformances

extension Option: ExpressibleByIntegerLiteral where Value: BinaryInteger, Value.IntegerLiteralType == Int {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(wrappedValue: Value(integerLiteral: value), nil) { $0.description }
    }
}

#if os(macOS)
    extension Option: ExpressibleByFloatLiteral where Value: BinaryFloatingPoint {
        public init(floatLiteral value: FloatLiteralType) {
            self.init(wrappedValue: Value(value), nil) { $0.formatted() }
        }
    }
#endif

extension Option: ExpressibleByExtendedGraphemeClusterLiteral where Value: StringProtocol {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(wrappedValue: Value(stringLiteral: value))
    }
}

extension Option: ExpressibleByUnicodeScalarLiteral where Value: StringProtocol {
    public init(unicodeScalarLiteral value: String) {
        self.init(wrappedValue: Value(stringLiteral: value))
    }
}

extension Option: ExpressibleByStringLiteral where Value: StringProtocol {
    public init(stringLiteral value: StringLiteralType) {
        self.init(wrappedValue: Value(stringLiteral: value))
    }
}

extension Option: ExpressibleByStringInterpolation where Value: StringProtocol {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(wrappedValue: Value(stringInterpolation: stringInterpolation))
    }
}

// MARK: Coding

extension Option: DecodableWithConfiguration where Value: Decodable {
    public init(from decoder: Decoder, configuration: @escaping @Sendable (Value) -> String?) throws {
        let container = try decoder.singleValueContainer()
        try self.init(wrappedValue: container.decode(Value.self), nil, configuration)
    }
}

extension Option: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        guard let configurationCodingUserInfoKey = Self.configurationCodingUserInfoKey() else {
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
        try self.init(from: decoder, configuration: configuration)
    }

    public static func configurationCodingUserInfoKey() -> CodingUserInfoKey? {
        CodingUserInfoKey(rawValue: "\(Self.self) - " + ObjectIdentifier(Self.self).debugDescription)
    }
}

extension Option: Encodable where Value: Encodable {
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
struct OptionEncoding {
    @Dependency(\.optionFormatter) var formatter

    let key: String
    let value: String

    func arguments() -> [String] {
        formatter.format(encoding: self)
    }
}

/*
 Since Option is generic, we need a single type to cast to in ArgumentGroup.
 OptionProtocol is that type and Option is the only type that conforms.
 */
protocol OptionProtocol {
    func arguments(key: String?) -> [String]
}
