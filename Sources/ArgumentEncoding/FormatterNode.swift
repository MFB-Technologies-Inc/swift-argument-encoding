// FormatterNode.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

/// A protocol that describes a type that defines how flags and options are formatted. Typically, `ArgumentGroup`
/// conforming types would be formatter nodes so that all their children will inherit the specified formatters.
public protocol FormatterNode {
    /// Formatter for all child `Flag`s
    var flagFormatter: FlagFormatter { get }

    /// Formatter for all child `Option`s
    var optionFormatter: OptionFormatter { get }
}
