//
//  StaticFactory.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

protocol StaticFactory {
    associatedtype Factory
}

extension StaticFactory {
    static var factory: Factory.Type { return Factory.self }
}
