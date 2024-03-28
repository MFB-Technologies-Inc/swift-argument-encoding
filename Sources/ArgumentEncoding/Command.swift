// Command.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

/// A command type argument with no nested or children arguments.
public struct Command: Hashable, Sendable, RawRepresentable {
    public let rawValue: String

    /// Accessor for `self` encoded as an array of argument strings - `[self.rawValue]`
    @inlinable
    public func arguments() -> [String] {
        guard !rawValue.isEmpty else {
            return []
        }
        return [rawValue]
    }

    @inlinable
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// ExpressibleBy...Literal conformances
extension Command: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}

extension Command: ExpressibleByStringInterpolation {
    @inlinable
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(rawValue: stringInterpolation.description)
    }
}
