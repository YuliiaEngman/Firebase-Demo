//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

enum ViewState {
    case myItems
    case favorites
}

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: DesignableImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private var selectedImage: UIImage? {
        didSet {
            profileImageView.image = selectedImage
        }
    }
    
    private let storageservice = StorageService()
    private let databaseService = DatabaseService()
    
    private var viewState: ViewState = .myItems {
        didSet {
            tableView.reloadData()
        }
    }
    
    // favorits
    //TODO: create Favorite model
    private var favorits = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // my items data
    private var myItems = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameTextField.delegate = self
        
        updateUI()
        tableView.dataSource = self
    }
    
    private func fetchItems() {
        // we need the current user id
        guard let user = Auth.auth().currentUser else { return }
        databaseService.fetchUserItems(userId: user.uid) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fetching error", message: error.localizedDescription)
                }
            case .success(let items):
                self?.myItems = items
            }
        }
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        emailLabel.text = user.email
        displayNameTextField.text = user.displayName
        profileImageView.kf.setImage(with: user.photoURL)
        //user.displayName
        //user.email
        //user.phoneNumber
        //user.photoURL
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
        //change the user's display name
        
        guard let displayName = displayNameTextField.text,
            !displayName.isEmpty, let selectedImage = selectedImage else {
                print("missing field")
                return
        }
        
        guard let user = Auth.auth().currentUser else { return }
        //resize image before uploading to Firebase
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImageView.bounds)
        
        print("original image size: \(selectedImage.size)")
        print("resized image size: \(resizedImage)")
        
        //TODO: call storageService.upload
        //need to update to user userId ot itemId
        storageservice.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
            // code here to add the photoURL to the user's photoURL
            //     property then commit changes
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                
                self?.updateDatabaseUser(displayName: displayName, photoURL: url.absoluteString)
                
                //TODO: refactor to own function
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                request?.displayName = displayName
                request?.photoURL = url
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error {
                        //TODO: show alert
                        //print("CommitCjanges error: \(error)")
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error updating profile", message: "Error changing profile: \(error.localizedDescription)")
                            
                        }
                    } else {
                        //print("profile successfully updated")
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Profile Updated", message: "Profile successfully updated")
                        }
                    }
                })
            }
        }
    }
    
    private func updateDatabaseUser(displayName: String, photoURL: String) {
        databaseService.updateDatabaseUser(displayName: displayName, photoURL: photoURL) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("failed to update db user: \(error.localizedDescription)")
            case .success:
                print("successfully updated db user")
            }
        }
        
    }
    
    
    
    @IBAction func editProfilePhotoButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        { [weak self] alertAction in
            self?.imagePickerController.sourceType = .camera
            self?.present(self!.imagePickerController, animated: true)
        }
        let phototLibararyAction = UIAlertAction(title: "Photo Libarary", style: .default)
        { [weak self] alertAction in
            self?.imagePickerController.sourceType = .photoLibrary
            self?.present(self!.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(phototLibararyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
            UIViewController.showViewController(storyboardName: "LoginView", viewControllerId: "LoginViewController")
        } catch {
            DispatchQueue.main.async {
                self.showAlert(title: "Error signing out", message: "\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        
        //toggle current viewState
        switch sender.selectedSegmentIndex {
        case 0:
            viewState = .myItems
        case 1:
            viewState = .favorites
        default:
            break
        }
    }
    
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        selectedImage = image
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewState == .myItems {
            return myItems.count
        } else {
            return favorits.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not downcast to ItemCell")
        }
        if viewState == .myItems {
            let item = myItems[indexPath.row]
            cell.configureCell(for: item)
        } else {
            let favorite = favorits[indexPath.row]
            //cell.configureCell(for: favorite)
        }
        return cell
      }
}
