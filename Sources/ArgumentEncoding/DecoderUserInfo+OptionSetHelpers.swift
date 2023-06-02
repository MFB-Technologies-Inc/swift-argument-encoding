// DecoderUserInfo+OptionSetHelpers.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Foundation

extension [CodingUserInfoKey: Any] {
    public mutating func addOptionSetConfiguration<T>(
        for _: T.Type,
        configuration: @escaping Option<T>.DecodingConfiguration
    ) where T: Decodable {
        guard let key = Option<T>.configurationCodingUserInfoKey() else {
            return
        }
        self[key] = configuration
    }

    public mutating func addOptionSetConfiguration<T>(
        for _: OptionSet<T>.Type,
        configuration: @escaping OptionSet<T>.DecodingConfiguration
    ) where T: Decodable {
        guard let key = OptionSet<T>.configurationCodingUserInfoKey() else {
            return
        }
        self[key] = configuration
    }

    public mutating func addOptionSetConfiguration<T>(for _: OptionSet<T>.Type) where T: Decodable, T: Sequence,
        T.Element: CustomStringConvertible
    {
        addOptionSetConfiguration(for: OptionSet<T>.self, configuration: OptionSet<T>.unwrap(_:))
    }

    public mutating func addOptionSetConfiguration<T>(for _: OptionSet<T>.Type) where T: Decodable, T: Sequence,
        T.Element: RawRepresentable, T.Element.RawValue: CustomStringConvertible
    {
        addOptionSetConfiguration(for: OptionSet<T>.self, configuration: OptionSet<T>.unwrap(_:))
    }

    public mutating func addOptionSetConfiguration<T>(for _: OptionSet<T>.Type) where T: Decodable, T: Sequence,
        T.Element: CustomStringConvertible, T.Element: RawRepresentable, T.Element.RawValue: CustomStringConvertible
    {
        addOptionSetConfiguration(for: OptionSet<T>.self, configuration: OptionSet<T>.unwrap(_:))
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
