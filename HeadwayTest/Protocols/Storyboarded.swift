//
//  Storyboarded.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit

protocol Storyboarded {
    static func instantiate(storyboardName name: String) -> Self
}

extension Storyboarded where Self: UIViewController {

    static func instantiate(storyboardName name: String = "Main") -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
