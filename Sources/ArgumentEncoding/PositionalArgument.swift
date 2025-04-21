// PositionalArgument.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import Foundation

/// A value only argument type that is not a command or sub-command.
///
/// Because positional argumnents do not have a key, they encode to only their value..
///
/// ```swift
/// struct Container: ArgumentGroup, FormatterNode {
///     let flagFormatter: FlagFormatter = .doubleDashPrefix
///     let optionFormatter: OptionFormatter = OptionFormatter(prefix: .doubleDash)
///
///     @Positional var name: String = "value"
/// }
///
/// Container().arguments() == ["value"]
/// ```
@propertyWrapper
public struct Positional<Value>: PositionalProtocol {
    public var wrappedValue: Value

    // Different Value types will encode to arguments differently.
    // Using unwrap, this can be handled individually per type or collectively by protocol
    private let unwrap: @Sendable (Value) -> [String]
    var unwrapped: [String] {
        unwrap(wrappedValue)
    }

    func encoding() -> [Command] {
        unwrapped.map(Command.init(rawValue:))
    }

    /// Get the Positional's argument encoding.
    /// - Returns: The argument encoding which is an array of strings
    public func arguments() -> [String] {
        encoding().flatMap { $0.arguments() }
    }

    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - unwrap: A closure for mapping a Value to [String]
    public init(value: Value, unwrap: @escaping @Sendable (Value) -> [String]) {
        wrappedValue = value
        self.unwrap = unwrap
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    ///     - _ unwrap: A closure for mapping a Value to [String]
    public init(wrappedValue: Value, _ unwrap: @escaping @Sendable (Value) -> [String]) {
        self.wrappedValue = wrappedValue
        self.unwrap = unwrap
    }
}

// MARK: Conditional Conformances

extension Positional: Equatable where Value: Equatable {
    public static func == (lhs: Positional<Value>, rhs: Positional<Value>) -> Bool {
        lhs.unwrapped == rhs.unwrapped
    }
}

extension Positional: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(unwrapped)
        hasher.combine(ObjectIdentifier(Self.self))
    }
}

extension Positional: Sendable where Value: Sendable {}

// MARK: Convenience initializers when Value: CustomStringConvertible

extension Positional where Value: CustomStringConvertible {
    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(value: Value) {
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value) -> [String] {
        [value.description]
    }
}

extension Positional where Value: RawRepresentable, Value.RawValue: CustomStringConvertible {
    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(value: Value) {
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value) -> [String] {
        [value.rawValue.description]
    }
}

extension Positional where Value: CustomStringConvertible, Value: RawRepresentable,
    Value.RawValue: CustomStringConvertible
{
    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(value: Value) {
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value) -> [String] {
        [value.rawValue.description]
    }
}

// MARK: Convenience initializers when Value == Positionalal<Wrapped>

extension Positional {
    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init<Wrapped>(value: Wrapped?) where Wrapped: CustomStringConvertible,
        Value == Wrapped?
    {
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init<Wrapped>(wrappedValue: Wrapped?) where Wrapped: CustomStringConvertible,
        Value == Wrapped?
    {
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap<Wrapped>(_ value: Wrapped?) -> [String] where Wrapped: CustomStringConvertible,
        Value == Wrapped?
    {
        [value?.description].compactMap { $0 }
    }
}

// MARK: Convenience initializers when Value == Sequence<E>

extension Positional {
    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init<E>(values: Value) where Value: Sequence, Value.Element == E,
        E: CustomStringConvertible
    {
        wrappedValue = values
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init<E>(wrappedValue: Value) where Value: Sequence, Value.Element == E,
        E: CustomStringConvertible
    {
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap<E>(_ value: Value) -> [String] where Value: Sequence, Value.Element == E,
        E: CustomStringConvertible
    {
        value.map(\E.description)
    }
}

// MARK: Convenience initializers when Value: ArgumentGroup

extension Positional where Value: ArgumentGroup {
    /// Initializes a new positional when not used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(value: Value) {
        wrappedValue = value
        unwrap = Self.unwrap(_:)
    }

    /// Initializes a new positional when used as a `@propertyWrapper`
    ///
    /// - Parameters
    ///     - wrappedValue: The underlying value
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        unwrap = Self.unwrap(_:)
    }

    @Sendable
    public static func unwrap(_ value: Value) -> [String] {
        value.arguments()
    }
}

// MARK: ExpressibleBy...Literal conformances

extension Positional: ExpressibleByIntegerLiteral where Value: BinaryInteger, Value.IntegerLiteralType == Int {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(wrappedValue: Value(integerLiteral: value)) { [$0.description] }
    }
}

#if os(macOS)
    extension Positional: ExpressibleByFloatLiteral where Value: BinaryFloatingPoint {
        public init(floatLiteral value: FloatLiteralType) {
            self.init(wrappedValue: Value(value)) { [$0.formatted()] }
        }
    }
#endif

extension Positional: ExpressibleByExtendedGraphemeClusterLiteral where Value: StringProtocol {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(wrappedValue: Value(stringLiteral: value))
    }
}

extension Positional: ExpressibleByUnicodeScalarLiteral where Value: StringProtocol {
    public init(unicodeScalarLiteral value: String) {
        self.init(wrappedValue: Value(stringLiteral: value))
    }
}

extension Positional: ExpressibleByStringLiteral where Value: StringProtocol {
    public init(stringLiteral value: StringLiteralType) {
        self.init(wrappedValue: Value(stringLiteral: value))
    }
}

extension Positional: ExpressibleByStringInterpolation where Value: StringProtocol {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(wrappedValue: Value(stringInterpolation: stringInterpolation))
    }
}

extension Positional: DecodableWithConfiguration where Value: Decodable {
    public init(from decoder: Decoder, configuration: @escaping @Sendable (Value) -> [String]) throws {
        let container = try decoder.singleValueContainer()
        try self.init(wrappedValue: container.decode(Value.self), configuration)
    }
}

// MARK: Coding

extension Positional: Decodable where Value: Decodable {
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
        try self.init(wrappedValue: container.decode(Value.self), configuration)
    }

    public static func configurationCodingUserInfoKey(for _: (some Any).Type) -> CodingUserInfoKey? {
        CodingUserInfoKey(rawValue: ObjectIdentifier(Self.self).debugDescription)
    }
}

extension Positional: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: Internal Types

/*
 Since Positional is generic, we need a single type to cast to in ArgumentGroup.
 PositionalProtocol is that type and Positional is the only type that conforms.
 */
protocol PositionalProtocol {
    func arguments() -> [String]
}
