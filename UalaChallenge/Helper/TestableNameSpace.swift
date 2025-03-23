//
//  TestableNameSpace.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 22/3/25.
//

#if DEBUG

import Foundation

// Base class for getting into the namespace

@MainActor
public final class TestableNamespace<Base> {

    public typealias Base = Base
    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

// Protocol to box the namespace automatically

@MainActor
public protocol TestableNamespaceConvertible {}

extension TestableNamespaceConvertible {

    public static var testable: TestableNamespace<Self>.Type {
        TestableNamespace<Self>.self
    }

    public var testable: TestableNamespace<Self> {
        TestableNamespace(self)
    }
}

#endif
