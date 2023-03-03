// TestCommand.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

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
