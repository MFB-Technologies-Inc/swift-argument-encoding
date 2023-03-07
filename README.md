# ArgumentEncoding

[![ci](https://github.com/MFB-Technologies-Inc/swift-argument-encoding/actions/workflows/ci.yml/badge.svg)](https://github.com/MFB-Technologies-Inc/swift-argument-encoding/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MFB-Technologies-Inc/swift-argument-encoding/branch/main/graph/badge.svg?token=UU95IDUXAX)](https://codecov.io/gh/MFB-Technologies-Inc/swift-argument-encoding)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMFB-Technologies-Inc%2Fswift-argument-encoding%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/MFB-Technologies-Inc/swift-argument-encoding)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMFB-Technologies-Inc%2Fswift-argument-encoding%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/MFB-Technologies-Inc/swift-argument-encoding)

A library for encoding types into an Array of Strings, or 'arguments'.

## Stability

This library is still a work in progress. It should be considered expiramental and may have breaking changes between feature releases until `1.0.0` is reached.

## Usage

Typically, modeling a CLI tool will begin with a `TopLevelCommandRepresentable`. This is the entry point and must explictely state it's own name via the `commandValue` function.

```swift
struct MyCommand: TopLevelCommandRepresentable {
    func commandValue() -> Command { "my-command" }
    var flagFormatter: FlagFormatter { .doubleDashPrefix }
    var optionFormatter: OptionFormatter { .doubleDashPrefix }
}
```

Each command or subcommand may have it's own formatting requirements for flags and options. Therefore, `TopLevelCommandRepresentable` and `CommandRepresentable` both inherit from `FormatterNode`. This requires a `FlagFormatter` and `OptionFormatter` be declared.

Within `MyCommand` we need the ability to model a boolean value to enable/disable some functionality. This is where `Flag` comes in. It is most convenient as a property wrapper within some `ArgumentGroup` conforming type.

```swift
struct MyCommand: TopLevelCommandRepresentable {
    func commandValue() -> Command { "my-command" }
    var flagFormatter: FlagFormatter { .doubleDashPrefix }
    var optionFormatter: OptionFormatter { .doubleDashPrefix }

    @Flag var myFlag: Bool = false
}
```

In addition to modeling the ability to enable/disable a feature, we need to set a value against some variable. For this, we can use `Option`.

```swift
struct MyCommand: TopLevelCommandRepresentable {
    func commandValue() -> Command { "my-command" }
    var flagFormatter: FlagFormatter { .doubleDashPrefix }
    var optionFormatter: OptionFormatter { .doubleDashPrefix }

    @Flag var myFlag: Bool = false
    @Option var myOption: Int = 0
}
```

## Motivation

When running executables with Swift, it may be helpful to encode structured types (struct, class, enum) into argument arrays that are passed to executables.

```swift
public enum SwiftCommand {
    case run(String)
    case test(TestCommand)

    public func asArgs() -> [String] {
        let childArgs: [String]
        switch self {
        case let .run(executableProduct):
            childArgs = [executableProduct]
        case let .test(testCommand):
            childArgs = testCommand.asArgs()
        }
        return ["swift"] + childArgs
    }
}

public struct TestCommand {
    public let parallel: Bool
    public let numWorkers: Int
    public let showCodecovPath: Bool
    public let testProducts: [String]

    public init(
        parallel: Bool = true,
        numWorkers: Int = 1,
        showCodecovPath: Bool = false,
        testProducts: [String]
    ) {
        self.parallel = parallel
        self.numWorkers = numWorkers
        self.showCodecovPath = showCodecovPath
        self.testProducts = testProducts
    }

    public func asArgs() -> [String] {
        var args = [String]()
        if parallel {
            args.append("--parallel")
        }
        args.append(contentsOf: ["--num-workers", numWorkers.description])
        if showCodecovPath {
            args.append("--show-codecov-path")
        }
        args.append(contentsOf: testProducts)
        return args
    }
}
```

This approach is tedious and error prone. There are ways to improve while still manually writing `asArgs` but it is still far from ideal.

ArgumentEncoding enables writing types that easily encode into argument arrays while requiring no manual encoding.

```swift
import ArgumentEncoding

enum SwiftCommand: TopLevelCommandRepresentable {
    func commandValue() -> Command { "swift" }

    var flagFormatter: FlagFormatter { .doubleDashPrefixKebabCase }
    var optionFormatter: OptionFormatter { .doubleDashPrefixKebabCase }

    case run(RunCommand)
    case test(TestCommand)
}

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

struct TestCommand: CommandRepresentable {
    let flagFormatter: FlagFormatter = .doubleDashPrefixKebabCase
    let optionFormatter: OptionFormatter = .doubleDashPrefixKebabCase

    @Flag var parallel: Bool = true
    @Option var numWorkers: Int = 1
    @Flag var showCodecovPath: Bool = false
    var testProducts: [Command]
}

extension [Command]: ArgumentGroup {}
```