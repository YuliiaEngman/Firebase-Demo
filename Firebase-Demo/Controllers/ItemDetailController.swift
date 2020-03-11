//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemDetailController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    private var item: Item
    private var originalValueForConstraint: CGFloat = 0
    
    private var databaseService = DatabaseService()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        return gesture
    }()
    
    private var listener: ListenerRegistration?
    
    private var comments = [Comment]() {
        didSet { // property observer
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a" //EEEE - Full day (Wednesday)
        return formatter
    }()
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = item.itemName
        
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        originalValueForConstraint = containerBottomConstraint.constant
        
        commentTextField.delegate = self
        
        view.addGestureRecognizer(tapGesture)
        
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        registerKeyboardNotifications()
        
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                //create comments using dictionary initialixer from the Comment model
//                self?.comments = snapshot.documents.map { Comment($0.data())}
                let comments = snapshot.documents.map { Comment($0.data())}
                //sort by date
                self?.comments = comments.sorted {$0.commentDate.dateValue() > $1.commentDate.dateValue()}
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
        listener?.remove()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        
        //TODO: add comment to the comments collection on this item
        // getting comment ready to post to firebase
        guard let commentText = commentTextField.text,
            !commentText.isEmpty else {
                showAlert(title: "Missing Fields", message: "A comment is requred")
                return
        }
        
        // post to firebase
        postComment(text: commentText)
    }
    
    private func postComment(text: String) {
        databaseService.postComment(item: item, comment: text) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again", message: error.localizedDescription)
                }
            case .success:
               DispatchQueue.main.async {
                    self?.showAlert(title: "Comment posted", message: nil)
                }
            }
        }
    }
    
    
    //Keyboard handling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print(notification.userInfo) // this is below UIKeyboardBoundUserInfoKey comes from here
        guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
            return
        }
        
        //adjust the container bottom constraint
        containerBottomConstraint.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
           dismissKeyboard()
       }
    
    @objc private func dismissKeyboard() {
        containerBottomConstraint.constant = originalValueForConstraint
        commentTextField.resignFirstResponder()
    }
}

extension ItemDetailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

extension ItemDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = comments[indexPath.row]
        let dateString = dateFormatter.string(from: comment.commentDate.dateValue())
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = "@" + comment.commentedBy + " " + dateString
        return cell
    }
    
    
}
