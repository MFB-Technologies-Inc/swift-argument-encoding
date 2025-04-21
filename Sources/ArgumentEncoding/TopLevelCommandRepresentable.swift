// TopLevelCommandRepresentable.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

/// A type that represents a command type argument that is not a child of an `ArgumentGroup`.
///
/// Implementations of TopLevelCommandRepresentable specify their own command value as a requirement of the protocol
///
/// ```swift
/// struct TopLevelGroup: TopLevelCommandRepresentable {
///     // Command Value
///     func commandValue() -> Command { "swift" }
///
///     // Formatters to satisfy `FormatterNode` requirements
///     let flagFormatter: FlagFormatter = .doubleDashPrefix
///     let optionFormatter: OptionFormatter = OptionFormatter(prefix: .doubleDash)
///
///     // Properties that represent the child arguments
///     @Flag var asyncMain: Bool
///     @Option var numThreads: Int = 0
///
///     init(asyncMain: Bool, numThreads: Int) {
///         self.asyncMain = asyncMain
///         self.numThreads = numThreads
///     }
/// }
///
///
/// let group = TopLevelGroup(asyncMain: false, numThreads: 1)
///
/// // ["swift", "--numThreads", "1"]
/// let arguments = container.arguments()
/// ```
///
/// `TopLevelCommandRepresentable` inherits from ``ArgumentGroup``, ``FormatterNode``, and ``CommandRepresentable``
public protocol TopLevelCommandRepresentable: CommandRepresentable, FormatterNode {
    func commandValue() -> Command
}

extension TopLevelCommandRepresentable {
    // Default implementation of `ArgumentGroup.arguments` that prefixes the child arguments with `Self.commandValue`.
    // Reflection via the `Mirror` API is used for child arguments.
    public func arguments() -> [String] {
        commandValue().arguments() + childArguments()
    }
}
