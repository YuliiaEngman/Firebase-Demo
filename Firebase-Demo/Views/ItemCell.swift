//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: DesignableImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    public func configureCell(for item: Item) {
        //setup image
        itemImageView.kf.setImage(with: URL(string: item.imageURL))
        itemNameLabel.text = item.itemName
        sellerNameLabel.text = "@\(item.sellerName)"
        dateLabel.text = item.listedDate.description
        let price = String(format: "%.2f", item.price)
        priceLabel.text = "$\(price)"
    }
}
