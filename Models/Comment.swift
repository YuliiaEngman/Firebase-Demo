//
//  Comment.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    let commentDate: Timestamp
    let commentedBy: String
    let itemId: String
    let itemName: String
    let sellerName: String
    let text: String
}

extension Comment {
    // we use this initializer when converting a snapshot firebase data oblect to our Swift model (Comment)
    init(_ dictionary: [String: Any]) {
        self.commentDate = dictionary["commentDate"] as? Timestamp ?? Timestamp(date: Date())
        self.commentedBy = dictionary["commentedBy"] as? String ?? "no commentedBy name"
        self.itemId = dictionary["itemId"] as? String ?? "no item id"
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.sellerName = dictionary["sellerName"] as? String ?? "no sellerName"
        self.text = dictionary["text"] as? String ?? "no text"
    }
}
