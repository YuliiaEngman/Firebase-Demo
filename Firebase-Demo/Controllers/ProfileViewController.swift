//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: DesignableImageView!
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        emailLabel.text = user.email
        displayNameTextField.text = user.displayName
        //user.displayName
        //user.email
        //user.phoneNumber
        //user.photoURL
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
        //change the user's display name
        
        guard let displayName = displayNameTextField.text,
            !displayName.isEmpty else {
                print("missing field")
                return
        }
        
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        
        request?.displayName = displayName
        
        request?.commitChanges(completion: {(error) in
            if let error = error {
                //TODO: show alert
                print("CommitCjanges error: \(error)")
            } else {
                print("profile successfully updated")
            }
        })
    }
}
