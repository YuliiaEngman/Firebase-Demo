//
//  File.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/22/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Favorite {
    let itemName: String
    let favoritedDate: Timestamp
    let imageURL: String
    let itemId: String
    let price: Double
    let sellerId: String
}

extension Favorite {
    // failable initializer:
    // all properties need to exsist in order for the object to het created
    // we can use it you 100% all the value will exist you can use failable initializer
    init?(_ dictionary: [String: Any]) {
        guard let itemName = dictionary["itemName"] as? String,
            let favoritedDate = dictionary["favoritedDate"] as? Timestamp,
        let imageURL = dictionary["imageURL"] as? String,
        let itemId = dictionary["itemId"] as? String,
        let price = dictionary["price"] as? Double,
            let sellerId = dictionary["sellerId"] as? String else {
                return nil
        }
        self.itemName = itemName
        self.favoritedDate = favoritedDate
        self.imageURL = imageURL
        self.itemId = itemId
        self.price = price
        self.sellerId = sellerId
    }
}
