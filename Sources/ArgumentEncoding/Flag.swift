// Flag.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies

public struct Flag: Sendable {
    public let key: String
    public var enabled: Bool

    public func arguments() -> [String] {
        if enabled {
            return [formatter.string(self)]
        } else {
            return []
        }
    }

    @Dependency(\.flagFormatter) var formatter

    public init(_ key: some CustomStringConvertible) {
        self.key = key.description
        enabled = true
    }

    public init?(_ key: some CustomStringConvertible, enabled: Bool?) {
        guard let enabled, enabled else {
            return nil
        }
        self.init(key)
    }
}

extension Flag: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Flag: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(stringInterpolation)
    }
}
