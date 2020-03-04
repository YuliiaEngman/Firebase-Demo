//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    // in our app we will be uploading a photo to storage in two places: 1. ProfileController
    //2. CreateItemVC
    
    //we will be creating two different buckets of folders 1. UserProfilePhotots/user.uid
   // 2. ItemsPhotos/itemId
    
    // lets create a referance to the Firebase storage
    private let storageRef = Storage.storage().reference()
    
    //making this func generic for either userId or itemId
    //default parameters in Swift e.g. userId: String? = nil
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
        
        //1. convert UIImage to Data because this is the object we are posting to Firebase Storage
        guard let imageData = image.jpegData(compressionQuality: 1.0) else // 1.0 is full compression
        {
            return
        }
        
        //we need to establish which bucket or collection or folder we will be saving the photo to
        var photoReferance: StorageReference!
        
        if let userId = userId {//coming from ProfileViewController
            photoReferance = storageRef.child("UserProfilePhotos/\(userId).jpeg")
        } else if let itemId = itemId { // coming from CreateItemViewController
            photoReferance = storageRef.child("ItemsPhotos/\(itemId).jpeg")
        }
    }
}
