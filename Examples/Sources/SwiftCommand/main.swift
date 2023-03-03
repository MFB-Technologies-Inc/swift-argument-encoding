// main.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

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
