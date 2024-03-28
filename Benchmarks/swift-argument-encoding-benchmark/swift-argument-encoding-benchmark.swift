// swift-argument-encoding-benchmark.swift
// ArgumentEncoding
//
// Copyright © 2024 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import ArgumentEncoding
import Benchmark
import Foundation

let benchmarks = {
    Benchmark("Encode a really big argument set", configuration: .init(metrics: .all)) { _, command in
        blackHole(command.arguments())
    } setup: {
        BigCommand.build(.init())
    }
}

enum BigCommand: TopLevelCommandRepresentable {
    case build(Build)
    case test(Test)
    case run(Run)

    struct Build: CommandRepresentable {
        @Option var target: String = UUID().uuidString
        @Option var parallelWorkers: Int = .random(in: Int.min ... Int.max)
        @Flag var release: Bool = .random()
        @OptionSet var arguments: [String] = (1 ... 10).map(\.description)
    }

    struct Test: CommandRepresentable {
        @Option var target: String = UUID().uuidString
        @Option var parallelWorkers: Int = .random(in: Int.min ... Int.max)
        @Flag var release: Bool = .random()
        @OptionSet var arguments: [String] = (1 ... 10).map(\.description)
    }

    struct Run: CommandRepresentable {
        @Option var target: String = UUID().uuidString
        @Option var parallelWorkers: Int = .random(in: Int.min ... Int.max)
        @Flag var release: Bool = .random()
        @OptionSet var arguments: [String] = (1 ... 10).map(\.description)
    }

    func commandValue() -> ArgumentEncoding.Command {
        "big-command"
    }

    var flagFormatter: ArgumentEncoding.FlagFormatter {
        FlagFormatter(prefix: .doubleDash, key: .kebabCase)
    }

    var optionFormatter: ArgumentEncoding.OptionFormatter {
        OptionFormatter(prefix: .singleDash, key: .singleQuote, separator: .separate, value: .snakeCase)
    }
}
