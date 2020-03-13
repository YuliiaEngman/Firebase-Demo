//
//  ItemModel.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct Item {
    let itemName: String
    let price: Double
    let itemId: String
    let listedDate: Date
    let sellerName: String
    let sellerId: String // it will be our ID
    let categoryName: String
    let imageURL: String
}

extension Item {
    init(_ dictionary: [String: Any]) {
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.price = dictionary["price"] as? Double ?? 0.0
        self.itemId = dictionary["itemID"] as? String ?? "no item id"
        self.listedDate = dictionary["listedDate"] as? Date ?? Date()
        self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
        self.sellerId = dictionary["sellerId"] as? String ?? "no sellet id"
        self.categoryName = dictionary["categoryName"] as? String ?? "no category name"
        self.imageURL = dictionary["imageURL"] as? String ?? "no image url"
    }
}
