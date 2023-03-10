// CaseConverter.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import Foundation

/// Convert from Swift's typical camelCase to kebab-case and snake_case as some argument formats require them.
public enum CaseConverter {
    public static let kebabCase: (String) -> String = fromCamelCase(template: "$1-$2")

    public static let snakeCase: (String) -> String = fromCamelCase(template: "$1_$2")

    private static func fromCamelCase(template: String) -> (String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: []) else {
            return { $0 }
        }
        return { input in
            let range = NSRange(location: 0, length: input.utf16.count)
            let result = regex.stringByReplacingMatches(in: input, range: range, withTemplate: template)
            return result.lowercased()
        }
    }
}
