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
    
    // 2 ways to fetch items:
// Authomatic refresh 1 - via add snapshotlictener as in ItemFeedViewController (  listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({...)
    // Set manually 2 - getDocuments or getDocument (inside this file)
    
    static let itemsCollection = "items" // to access static let we use class name + let itself
    static let userCollection = "users"
    static let commentsCollection = "comments" //sub-collection on an item document
    static let favoritsCollection = "favorites" //sub-collection on a user document
    
    // review - firebase firestore hierarchy works like this
    // top level
    // collection -> document -> collection -> document -> ...
    
    //let's get a refetance to the Firebase Firestore database
    
    private let db = Firestore.firestore()
    //db represent a top collection
    //each project will have its own database
    
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
        //           let sellerId: String -> user.uid (uid - is unique number that assigned to the user who just created their account).
        //            let categoryName: String
        //        }
        
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["itemName":itemName, "price":price, "itemID":documentRef.documentID, "listedDate":Timestamp(date: Date()), "sellerName":displayName, "sellerId":user.uid, "categoryName":category.name]) {
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
    
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let email = authDataResult.user.email else {
            return
        }
        
        //in below code we could add a display name if we created that
        db.collection(DatabaseService.userCollection).document(authDataResult.user.uid).setData(["email" : email,
                                                                                                 "createdDate" : Timestamp(date: Date()),
                                                                                                 "userID": authDataResult.user.uid]) { (error) in
                                                                                                    
                                                                                                    if let error = error {
                                                                                                        completion(.failure(error))
                                                                                                    } else {
                                                                                                        completion(.success(true))
                                                                                                    }
        }
    }
    
    func updateDatabaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.userCollection).document(user.uid).updateData(["photoURL": photoURL, "displayName": displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func delete(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func postComment(item: Item, comment: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser, let displayName = user.displayName else {
            print("missing user data")
            return
        }
        //creating empty document I want to write
        //getting a document
        let docRef = db.collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).document()
        
        //actually writing to this document
        //using document from above to write (to firebase) -> to its contents to firebase
        db.collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).document(docRef.documentID).setData(["text":comment, "commentDate":Timestamp(date: Date()), "itemName": item.itemName, "itemId": item.itemId, "sellerName": item.sellerName, "commentedBy":displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func addToFavorits(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritsCollection).document(item.itemId).setData(["itemName": item.itemName, "price" : item.price, "imageURL": item.imageURL, "favoritedDate" : Timestamp(date: Date()), "itemId": item.itemId, "sellerName": item.sellerName, "sellerId": item.sellerId]) { (error) in
            
            if let error = error  {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func removeFromFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritsCollection).document(item.itemId).delete {(error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func isItemInFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        // in Firebase we use the "where" keyboard to query (search) a collection
        
        // getDocumet - gets (fetches) documents 1 time (ONLY ONCE)
        // addListener - any time there is a change I get an update on it (addSnapshotListener)
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritsCollection).whereField("itemId", isEqualTo: item.itemId).getDocuments {
            (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let count = snapshot.documents.count // check if we have documents
                if count > 0 {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        
        //snapshot is terminology that Firebase uses to represent current stage of the data
        db.collection(DatabaseService.itemsCollection).whereField(Constants.sellerId, isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map { Item($0.data())}
                completion(.success(items))
            }
            
        }
    }
    
    
    //we could take and userId and takes all his collection - but for not we are doing it differently
    public func fetchFavorites(completion: @escaping (Result<[Favorite], Error>) -> ()) {
        // access the usersCollection -> userid (document) -> favorits collection
        guard let user = Auth.auth().currentUser else  { return }
       
        //always start with collection (not document(s))
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritsCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                // we cannot use map here because there is a posibility that one of our object is nil
                // but we can use compact map even if the object could be nill - removes nill values from an array (ex. [4, nil, 12, -9, nil] -> [4, 12, -9])
                // our failable initializer returns us optional: init?() => Favorite?
                let favorits = snapshot.documents.compactMap { Favorite($0.data()) }
                completion(.success(favorits))
            }
        }
    }
}

