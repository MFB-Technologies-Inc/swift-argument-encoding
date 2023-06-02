// DecoderUserInfo+OptionHelpers.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Foundation

/// Helper functions for configuring a decoder's `userInfo` dictionary for decoding `Option`.
/// Each of the overloads that does not require the configuration closure, will configure both
/// `Option<T>` and `Option<T?>`.
///
/// ```swift
/// struct Container: ArgumentGroup, FormatterNode {
///     let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
///     let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)
///     @Option var option: String = "value"
/// }
/// let encoded = try JSONEncoder().encode(Container())
/// let decoder = JSONDecoder()
/// decoder.userInfo.addOptionConfiguration(for: String.self)
/// let decoded = try decoder.decode(Container.self, from: encoded)
/// // decoded = ["--option", "value"]
/// ```
extension [CodingUserInfoKey: Any] {
    public mutating func addOptionConfiguration<T>(
        for _: T.Type,
        configuration: @escaping Option<T>.DecodingConfiguration
    ) where T: Decodable {
        guard let key = Option<T>.configurationCodingUserInfoKey() else {
            return
        }
        self[key] = configuration
    }

    public mutating func addOptionConfiguration<T>(for _: T.Type) where T: Decodable,
        T: CustomStringConvertible
    {
        addOptionConfiguration(for: T.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: T.self, configuration: Option<T?>.unwrap(_:))
    }

    public mutating func addOptionConfiguration<T>(for _: T.Type) where T: Decodable, T: RawRepresentable,
        T.RawValue: CustomStringConvertible
    {
        addOptionConfiguration(for: T.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: T.self, configuration: { $0.rawValue.description })
    }

    public mutating func addOptionConfiguration<T>(for _: T.Type) where T: Decodable, T: CustomStringConvertible,
        T: RawRepresentable, T.RawValue: CustomStringConvertible
    {
        addOptionConfiguration(for: T.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: T.self, configuration: Option<T?>.unwrap(_:))
    }
}
