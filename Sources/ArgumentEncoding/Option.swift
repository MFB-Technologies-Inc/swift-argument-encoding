// Option.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies

/// A key/value pair argument that provides a given value for a option or variable.
public struct Option: Sendable {
    public let key: String
    public var value: String

    public func arguments() -> [String] {
        formatter.strings(self)
    }

    @Dependency(\.optionFormatter) var formatter

    public init(key: some CustomStringConvertible, value: some CustomStringConvertible) {
        self.key = key.description
        self.value = value.description
    }

    public init?(key: some CustomStringConvertible, value: (some CustomStringConvertible)?) {
        guard let value else {
            return nil
        }
        self.init(key: key, value: value)
    }
}
