// RunCommand.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding

struct RunCommand: CommandRepresentable {
    let flagFormatter: FlagFormatter = .doubleDashPrefixKebabCase
    let optionFormatter: OptionFormatter = .doubleDashPrefixKebabCase

    let executable: Command
}

extension RunCommand: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(executable: Command(rawValue: value))
    }
}
