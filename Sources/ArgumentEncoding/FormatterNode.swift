// FormatterNode.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

/// A protocol that describes a type that defines how flags and options are formatted. Typically, `ArgumentGroup`
/// conforming types would be formatter nodes so that all their children will inherit the specified formatters.
public protocol FormatterNode {
    /// Formatter for all child `Flag`s
    var flagFormatter: FlagFormatter { get }

    /// Formatter for all child `Option`s
    var optionFormatter: OptionFormatter { get }
}
