// RunCommand.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

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
