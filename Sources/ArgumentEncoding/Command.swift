// Command.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

public struct Command: Hashable, Sendable, RawRepresentable {
    public let rawValue: String

    public func arguments() -> [String] {
        [rawValue]
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Command: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}

extension Command: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(rawValue: stringInterpolation.description)
    }
}
