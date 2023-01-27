// CommandRepresentable.swift
// ArgumentEncoding
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.

public protocol CommandRepresentable {
    static var rawValue: String { get }
}

extension ArgumentRepresentable where Self: CommandRepresentable {
    public func arguments() -> [String] {
        CollectionOfOne(Self.rawValue) + childArguments()
    }
}
