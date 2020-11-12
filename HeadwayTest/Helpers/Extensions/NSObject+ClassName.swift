//
//  NSObject+ClassName.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
