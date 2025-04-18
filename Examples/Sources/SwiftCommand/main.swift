// main.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

let test = SwiftCommand.test(TestCommand(
    parallel: true,
    numWorkers: 4,
    showCodecovPath: true,
    testProducts: ["swiftlint"]
))
let run = SwiftCommand.run("swiftlint")
print("""
SwiftCommand.test(TestCommand(
    parallel: true,
    numWorkers: 4,
    showCodecovPath: true,
    testProducts: ["swiftlint"]
))

\(test.arguments())

-------------------------------

SwiftCommand.run("swiftlint")

\(run.arguments())
""")
