// CommandRepresentable.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import Dependencies

/// A type that represents a command type argument and contains child arguments.
///
/// Implementations of CommandRepresentable get their command value contextually.
///
/// ```swift
/// struct ParentGroup: CommandRepresentable {
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
/// struct Container: ArgumentGroup, FormatterNode {
///     let parent: ParentGroup
/// }
///
/// let container = Container(parent: ParentGroup(asyncMain: false, numThreads: 1)
///
/// // ["parent", "--numThreads", "1"]
/// let arguments = container.arguments()
/// ```
///
/// `CommandRepresentable` inherits from ``ArgumentGroup``
public protocol CommandRepresentable: ArgumentGroup {}

extension CommandRepresentable {
    /// Prefixes the child arguments with an explicit command value.
    /// Reflection via the `Mirror` API is used for child arguments.
    ///
    /// - Parameters
    ///   - command: Explicit command value to prefix all child arguments
    /// - Returns
    ///   - Array of string arguments
    public func arguments(command: Command) -> [String] {
        command.arguments() + childArguments()
    }
}
