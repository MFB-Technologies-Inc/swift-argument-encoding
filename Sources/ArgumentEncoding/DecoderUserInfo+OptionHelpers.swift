// DecoderUserInfo+OptionHelpers.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Foundation

extension [CodingUserInfoKey: Any] {
    public mutating func addOptionConfiguration<T>(
        for _: Option<T>.Type,
        configuration: @escaping Option<T>.DecodingConfiguration
    ) where T: Decodable {
        guard let key = Option<T>.configurationCodingUserInfoKey() else {
            return
        }
        self[key] = configuration
    }

    public mutating func addOptionConfiguration<T>(for _: Option<T>.Type) where T: Decodable,
        T: CustomStringConvertible
    {
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T?>.unwrap(_:))
    }

    public mutating func addOptionConfiguration<T>(for _: Option<T>.Type) where T: Decodable, T: RawRepresentable,
        T.RawValue: CustomStringConvertible
    {
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: Option<T>.self, configuration: { $0.rawValue.description })
    }

    public mutating func addOptionConfiguration<T>(for _: Option<T>.Type) where T: Decodable,
        T: CustomStringConvertible,
        T: RawRepresentable, T.RawValue: CustomStringConvertible
    {
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T?>.unwrap(_:))
    }

    public mutating func addOptionConfiguration<T>(for _: T.Type) where T: Decodable,
        T: CustomStringConvertible
    {
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T?>.unwrap(_:))
    }

    public mutating func addOptionConfiguration<T>(for _: T.Type) where T: Decodable, T: RawRepresentable,
        T.RawValue: CustomStringConvertible
    {
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: Option<T>.self, configuration: { $0.rawValue.description })
    }

    public mutating func addOptionConfiguration<T>(for _: T.Type) where T: Decodable, T: CustomStringConvertible,
        T: RawRepresentable, T.RawValue: CustomStringConvertible
    {
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T>.unwrap(_:))
        addOptionConfiguration(for: Option<T>.self, configuration: Option<T?>.unwrap(_:))
    }
}
