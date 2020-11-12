//
//  UITextField+Style.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import UIKit

extension UITextField {
    
    func style(with title: String) {
        self.borderWidth = 1
        self.borderColor = UIColor.black.withAlphaComponent(0.3)
        self.attributedPlaceholder = NSAttributedString(string: title,
                                                        attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.3)])
        self.cornerRadius = self.frame.height / 2.5
    }
}
