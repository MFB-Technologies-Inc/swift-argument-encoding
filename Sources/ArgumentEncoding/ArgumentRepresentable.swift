// ArgumentRepresentable.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

public protocol ArgumentRepresentable {
    func arguments() -> [String]
}

extension ArgumentRepresentable {
    public func arguments() -> [String] {
        childArguments()
    }

    func childArguments() -> [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.flatMap { child in
            if let command = child as? Command {
                return command.arguments()
            } else if let flag = child as? Flag {
                return flag.arguments()
            } else if let option = child as? Option {
                return option.arguments()
            } else {
                return []
            }
        }
    }
}
