// FlagFormatter.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Dependencies
import XCTestDynamicOverlay

/// Formats `Flag`s to match how different executables format arguments
public struct FlagFormatter {
    private let format: (Flag) -> String

    @inline(__always)
    public func string(_ flag: Flag) -> String {
        format(flag)
    }

    public init(_ format: @escaping (Flag) -> String) {
        self.format = format
    }
}

extension FlagFormatter {
    public static let singleDashPrefix = FlagFormatter { StaticString.singleDash.description + $0.key }

    public static let doubleDashPrefix = FlagFormatter { StaticString.doubleDash.description + $0.key }
}

extension FlagFormatter: TestDependencyKey {
    public static let testValue: FlagFormatter = .unimplemented
}

extension DependencyValues {
    public var flagFormatter: FlagFormatter {
        get { self[FlagFormatter.self] }
        set { self[FlagFormatter.self] = newValue }
    }
}

extension FlagFormatter {
    public static let unimplemented = FlagFormatter(XCTestDynamicOverlay.unimplemented())
}
