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
        
        displayNameTextField.delegate = self
        
      updateUI()
    }
    
    private func updateUI() {
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
        
        request?.commitChanges(completion: { [unowned self] (error) in
            if let error = error {
                //TODO: show alert
                //print("CommitCjanges error: \(error)")
                self.showAlert(title: "Profile Change", message: "Error changing profile: \(error)")
            } else {
                //print("profile successfully updated")
                self.showAlert(title: "Profile Updated", message: "Profile successfully updated")
            }
        })
    }
    
    @IBAction func editProfilePhotoButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Photot Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: nil)
        let phototLibararyAction = UIAlertAction(title: "Photo Libarary", style: .cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(phototLibararyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
