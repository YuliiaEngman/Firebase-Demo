//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "try again later", message: "\(error.localizedDescription)")
                }
            } else if let snapshot = snapshot {
                print("there are \(snapshot.documents.count) item for sale")
                
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove() //no longer are we listening for cjanges from Firebase
    }
}

extension ItemFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        return cell
    }
}
