// TestCommand.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding

struct TestCommand: CommandRepresentable {
    let flagFormatter: FlagFormatter = .init(prefix: .doubleDash, key: .kebabCase)
    let optionFormatter: OptionFormatter = .init(prefix: .doubleDash, key: .kebabCase)

    @Flag var parallel: Bool = true
    @Option var numWorkers: Int = 1
    @Flag var showCodecovPath: Bool = false
    var testProducts: [Command]
}

extension [Command]: @retroactive ArgumentGroup {}
