// DecoderUserInfo+OptionSetHelpers.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

/// Helper functions for configuring a decoder's `userInfo` dictionary for decoding `OptionSet`.
/// Each of the overloads that does not require the configuration closure, will configure both
/// `OptionSet<T>` and `OptionSet<T?>`.
///
/// ```swift
/// struct Container: ArgumentGroup, FormatterNode {
///     let flagFormatter: FlagFormatter = .init(prefix: .doubleDash)
///     let optionFormatter: OptionFormatter = .init(prefix: .doubleDash)
///     @OptionSet var option: [String] = ["value1", "value2"]
/// }
/// let encoded = try JSONEncoder().encode(Container())
/// let decoder = JSONDecoder()
/// decoder.userInfo.addOptionConfiguration(for: String.self)
/// let decoded = try decoder.decode(Container.self, from: encoded)
/// // decoded = ["--option", "value1", "--option", "value2"]
/// ```
extension [CodingUserInfoKey: Any] {
    public mutating func addOptionSetConfiguration<T>(
        for _: OptionSet<T>.Type,
        configuration: @escaping OptionSet<T>.DecodingConfiguration
    ) where T: Decodable {
        guard let key = OptionSet<T>.configurationCodingUserInfoKey() else {
            return
        }
        self[key] = configuration
    }

    public mutating func addOptionSetConfiguration<T>(for _: T.Type) where T: Decodable, T: Sequence,
        T.Element: CustomStringConvertible
    {
        addOptionSetConfiguration(for: OptionSet<T>.self, configuration: OptionSet<T>.unwrap(_:))
    }

    public mutating func addOptionSetConfiguration<T>(for _: T.Type) where T: Decodable, T: Sequence,
        T.Element: RawRepresentable, T.Element.RawValue: CustomStringConvertible
    {
        addOptionSetConfiguration(for: OptionSet<T>.self, configuration: OptionSet<T>.unwrap(_:))
    }

    public mutating func addOptionSetConfiguration<T>(for _: T.Type) where T: Decodable, T: Sequence,
        T.Element: CustomStringConvertible, T.Element: RawRepresentable, T.Element.RawValue: CustomStringConvertible
    {
        addOptionSetConfiguration(for: OptionSet<T>.self, configuration: OptionSet<T>.unwrap(_:))
    }
}
