// TestCommand.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding

struct TestCommand: CommandRepresentable {
    let flagFormatter: FlagFormatter = .doubleDashPrefixKebabCase
    let optionFormatter: OptionFormatter = .doubleDashPrefixKebabCase

    @Flag var parallel: Bool = true
    @Option var numWorkers: Int = 1
    @Flag var showCodecovPath: Bool = false
    var testProducts: [Command]
}

extension [Command]: ArgumentGroup {}
