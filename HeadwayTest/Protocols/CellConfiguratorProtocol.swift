//
//  CellConfiguratorProtocol.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit

protocol CellConfiguratorProtocol {
    static var cellClass: AnyClass { get }
    static var cellNib: UINib { get }
    static var identifier: String { get }
}
