// SwiftCommand.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding

enum SwiftCommand: TopLevelCommandRepresentable {
    func commandValue() -> Command { "swift" }

    var flagFormatter: FlagFormatter { .doubleDashPrefixKebabCase }
    var optionFormatter: OptionFormatter { .doubleDashPrefixKebabCase }

    case run(RunCommand)
    case test(TestCommand)
}
