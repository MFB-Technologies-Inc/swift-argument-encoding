// RunCommand.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding

struct RunCommand: CommandRepresentable {
    let flagFormatter: FlagFormatter = .init(prefix: .doubleDash, key: .kebabCase)
    let optionFormatter: OptionFormatter = .init(prefix: .doubleDash, key: .kebabCase)

    let executable: Command
}

extension RunCommand: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(executable: Command(rawValue: value))
    }
}
