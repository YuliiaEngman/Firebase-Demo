//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by Yuliia Engman on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class ItemDetailController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    private var item: Item
    
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
        
        //tableView.tableHeaderView = UIView()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
    }
    
    

}
