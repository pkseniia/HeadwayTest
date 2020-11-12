//
//  SearchResultItemTableViewCell.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import Nuke

class SearchResultItemTableViewCell: UITableViewCell {

    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var itemImageView: UIImageView!
    @IBOutlet private(set) var seenImageView: UIImageView!
}

extension SearchResultItemTableViewCell {
    func configure(withRepoItem item: SearchResultItem, selectedItems: [SearchResultItem]) {
        if let url = item.imageUrl {
            Nuke.loadImage(with: URL(string: url)!, into: itemImageView)
        }
        titleLabel.text = item.name
        self.seenImageView.isHidden = selectedItems.contains(where: { $0.id == item.id}) ? false : true
    }
}


extension SearchResultItemTableViewCell: CellConfiguratorProtocol {
    static var cellClass: AnyClass {
        return SearchResultItemTableViewCell.self
    }

    static var cellNib: UINib {
        return UINib(nibName: SearchResultItemTableViewCell.className, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: cellClass)
    }
}
