// SwiftCommand.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

import ArgumentEncoding

enum SwiftCommand: TopLevelCommandRepresentable {
    func commandValue() -> Command { "swift" }

    var flagFormatter: FlagFormatter { .doubleDashPrefixKebabCase }
    var optionFormatter: OptionFormatter { .doubleDashPrefixKebabCase }

    case run(RunCommand)
    case test(TestCommand)
}
