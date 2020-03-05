//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
    
    static let itemsCollection = "items" // to actess statis let we use class name + let itself
    
    //let's get a refetance to the Firebase Firestore database
    
    private let db = Firestore.firestore()
    //db represent a top collection
    //eacj project will have its own database
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        //user if optional and we need to use guard for it
        
        guard let user = Auth.auth().currentUser else { return }
        
        //generate a document ID (we saving the item = document (anything, any piece of data)
        
        //here we generate a document for the "items" collection
        let documentRef = db.collection(DatabaseService.itemsCollection).document()
        
        //create a document in our "items" collection
       
        //key:value data (dictionary for Farebase):
        
//        struct Item {
//            let itemName: String
//            let price: Double
//            let itemId: String
//            let listedDate: Date -> current date represnted as Date()
//            let sellerName: String
//           let sellerID: String -> user.uid (uid - is unique number that assigned to the user who just created their account).
//            let categoryName: String
//        }
        
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["itemName":itemName, "price":price, "itemID":documentRef.documentID, "listedDate":Timestamp(date: Date()), "sellerName":displayName, "sellerID":user.uid, "categoryName":category.name]) {
            (error) in
            if let error = error {
               // print("error creating item: \(error)")
                completion(.failure(error))
            } else {
               // print("item was created \(documentRef.documentID)")
                completion(.success(documentRef.documentID))
            }
        }
    }
}
