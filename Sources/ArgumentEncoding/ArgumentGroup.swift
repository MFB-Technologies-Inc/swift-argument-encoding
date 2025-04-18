// ArgumentGroup.swift
// ArgumentEncoding
//
// This source code is licensed under the MIT License (MIT) found in the
// LICENSE file in the root directory of this source tree.

import Dependencies

/// A type that represents a group or collection of arguments
///
/// Types conform to this protocol so that any child ``Command``, ``CommandRepresentable``,
/// ``TopLevelCommandRepresentable``,  ``Flag``,
/// ``Option``, or ``ArgumentGroup`` will be encoded into an argument array.
///
/// ```swift
/// struct ParentGroup: ArgumentGroup {
///
///     // Properties that represent the child arguments
///     @Flag var asyncMain: Bool
///     @Option var numThreads: Int = 0
///     var child: ChildGroup
///
///     init(asyncMain: Bool, numThreads: Int, child: ChildGroup) {
///         self.asyncMain = asyncMain
///         self.numThreads = numThreads
///         self.child = child
///     }
///
///     // Nested `ArgumentGroup` that is encoded like any other child argument types.
///     struct ChildGroup: ArgumentGroup {
///
///         @Option var configuration: Configuration = .arm64
///         @Flag var buildTests: Bool
///
///         init(configuration: Configuration, buildTests: Bool) {
///             self.configuration = configuration
///             self.buildTests = buildTests
///         }
///
///         enum Configuration: String {
///             case arm64
///             case x86_64
///         }
///     }
/// }
/// ```
public protocol ArgumentGroup {
    /// The accessor for the computed array of arguments
    /// - Returns
    ///   - Array of string arguments
    func arguments() -> [String]
}

extension ArgumentGroup {
    /// Default implementation that uses reflection via the `Mirror` API to encode child arguments.
    public func arguments() -> [String] {
        childArguments()
    }

    func childArguments() -> [String] {
        applyFormatters(subject: self, operation: {
            let mirror = Mirror(reflecting: self)

            // Depending on the underlying type, we need to interpret the reflected information differently.
            switch mirror.displayStyle {
            case .enum:
                return childEnumArgument(subject: self, mirror: mirror)
            case .class, .struct, .tuple:
                return mirror.children.flatMap(childArgument(_:))
            case .collection, .set:
                return mirror.children.flatMap { element -> [String] in
                    guard let container = cast(value: element.value) else {
                        return []
                    }
                    return childArgument(label: nil, value: container, subject: element.value)
                }
            case .dictionary:
                return mirror.children.flatMap(childKeyValuePairArgument)
            case .optional:
                guard let child = mirror.children.first, let container = cast(value: child) else {
                    return []
                }
                return childArgument(label: nil, value: container, subject: child.value)
            case .none, .some:
                return []
            }
        })
    }

    // Handle `struct`, `class`, and `tuple` types
    private func childArgument(_ child: Mirror.Child) -> [String] {
        guard let value = cast(value: child.value) else {
            return []
        }
        return childArgument(label: child.label, value: value, subject: child.value)
    }

    // Convert the provided `Any` value to a `Container` to reveal the underlying argument type.
    private func cast(value: Any) -> Container? {
        if let container = value as? Container {
            return container
        } else if let option = value as? OptionProtocol {
            return .option(option)
        } else if let optionSet = value as? OptionSetProtocol {
            return .optionSet(optionSet)
        } else if let flag = value as? Flag {
            return .flag(flag)
        } else if let command = value as? Command {
            return .command(command)
        } else if let topLevelCommandRep = value as? (any TopLevelCommandRepresentable) {
            return .topLevelCommandRep(topLevelCommandRep)
        } else if let commandRep = value as? (any CommandRepresentable) {
            return .commandRep(commandRep)
        } else if let group = value as? (any ArgumentGroup) {
            return .group(group)
        } else if let positional = value as? PositionalProtocol {
            return .positional(positional)
        } else {
            return nil
        }
    }

    // Produce the actual array of arguments from a label and `Container`
    private func childArgument(label _label: String?, value: Container, subject: Any) -> [String] {
        applyFormatters(subject: subject, operation: {
            let label = trimLeadingUnderscore(_label)
            switch value {
            case let .option(option):
                return option.arguments(key: label)
            case let .optionSet(optionSet):
                return optionSet.arguments(key: label)
            case let .flag(flag):
                return flag.arguments(key: label)
            case let .command(command):
                return command.arguments()
            case let .topLevelCommandRep(topLevelCommandRep):
                return topLevelCommandRep.arguments()
            case let .commandRep(commandRep):
                if let label {
                    return commandRep.arguments(command: Command(rawValue: label))
                } else {
                    return commandRep.arguments()
                }
            case let .group(group):
                return group.arguments()
            case let .positional(positional):
                return positional.arguments()
            }
        })
    }

    private func applyFormatters(subject: Any, operation: @escaping () -> [String]) -> [String] {
        if let node = subject as? (any FormatterNode) {
            return withDependencies { values in
                values.flagFormatter = node.flagFormatter
                values.optionFormatter = node.optionFormatter
            } operation: {
                operation()
            }
        } else {
            return operation()
        }
    }

    // Handle key-value pairs like a `Dictionary.Element`
    private func childKeyValuePairArgument(_ child: Mirror.Child) -> [String] {
        guard let keyValuePair = child.value as? (any CustomStringConvertible, Any),
              let value = cast(value: keyValuePair.1)
        else {
            return []
        }
        return childArgument(label: keyValuePair.0.description, value: value, subject: keyValuePair.1)
    }

    // If working with a property wrapper, the wrapped value is prefixed with a '_'.
    // We don't want to leave that if the property name is used as the key.
    private func trimLeadingUnderscore(_ label: String?) -> String? {
        if let label, label.first == "_" {
            return label.dropFirst(1).description
        } else {
            return label
        }
    }

    // Handle `enum` types
    private func childEnumArgument(subject: Any, mirror: Mirror) -> [String] {
        let container = cast(value: subject)
        let subjectLabel: [String]
        switch container {
        case .commandRep:
            if let caseName = caseName(mirror: mirror) {
                subjectLabel = [caseName]
            } else {
                subjectLabel = []
            }
        default:
            subjectLabel = []
        }

        // Sort by key to make associated value order deterministic
        let associatedValues = associatedValues(mirror: mirror).sorted(by: { lhs, rhs in
            lhs.key < rhs.key
        })
        if associatedValues.count == 1, let onlyValue = associatedValues.first {
            if onlyValue.key.isEmpty {
                return associatedValue(
                    fallbackLabel: caseName(mirror: mirror),
                    key: onlyValue.key,
                    value: onlyValue.value
                )
            } else {
                return associatedValue(fallbackLabel: nil, key: onlyValue.key, value: onlyValue.value)
            }
        } else {
            return subjectLabel + associatedValues.reduce([String]()) { acc, keyValuePair in
                acc + associatedValue(fallbackLabel: nil, key: keyValuePair.key, value: keyValuePair.value)
            }
        }
    }

    private func associatedValue(fallbackLabel: String?, key: String, value: Any) -> [String] {
        guard let container = cast(value: value) else {
            return []
        }
        if key.isEmpty {
            return childArgument(label: fallbackLabel ?? "", value: container, subject: value)
        } else {
            return childArgument(label: key, value: container, subject: value)
        }
    }

    // Access associated values of an `enum` case
    private func associatedValues(mirror: Mirror) -> [String: Container] {
        guard let child = mirror.children.first else {
            return [:]
        }
        let childMirror = Mirror(reflecting: child.value)
        if childMirror.displayStyle == .tuple {
            return associatedValues(mirror: childMirror)
        } else {
            return mirror.children.reduce(into: [String: Container]()) { acc, keyValuePair in
                guard let container = cast(value: keyValuePair.value) else {
                    return
                }
                acc[keyValuePair.label ?? "NO_LABEL"] = container
            }
        }
    }

    // Access name of an `enum` case
    private func caseName(mirror: Mirror) -> String? {
        guard let caseName = mirror.children.first?.label else {
            return nil
        }
        return caseName
    }
}

// Represents the possible underlying argument types
private enum Container {
    case option(any OptionProtocol)
    case optionSet(any OptionSetProtocol)
    case flag(Flag)
    case command(Command)
    case topLevelCommandRep(any TopLevelCommandRepresentable)
    case commandRep(any CommandRepresentable)
    case group(any ArgumentGroup)
    case positional(any PositionalProtocol)
}
