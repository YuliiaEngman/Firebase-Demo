//
//  ViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 2/28/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

enum AccountState {
    case existingUser
    case newUser
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountStateMessageLabel: UILabel!
    @IBOutlet weak var accountStateButton: UIButton!
    
    private var accountState: AccountState = .existingUser
    
    private var authSession = AuthentificationSession()
    private var databaseService = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearErrorLabel()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        //print("login button pressed")
        
        guard let email = emailTextField.text,
            !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty else {
                print("missing fields")
                return
        }
        continueLoginFlow(email: email, password: password)
    }
    
    private func continueLoginFlow(email: String, password: String) {
        if accountState == .existingUser {
            authSession.signExistingUser(email: email, password: password) {[weak self](result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorLabel.text =
                            // localizedDescription - gives human redable description of the error
                        "\(error.localizedDescription)"
                        self?.errorLabel.textColor = .systemRed
                    }
               // case .success(let authDataResult):
                    case .success:
                    DispatchQueue.main.async {
//                        self?.errorLabel.text = "Welcome back user with email: \(authDataResult.user.email ?? "")"
//                        self?.errorLabel.textColor = .systemGreen
                        
                        //TODO: navigate to the main view
                        self?.navigateToMainView()
                    }
                }
            }
        } else {
            authSession.createNewuser(email: email, password: password) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorLabel.text =
                            // localizedDescription - gives human redable description of the error
                        "\(error.localizedDescription)"
                        self?.errorLabel.textColor = .systemRed
                    }
                //case .success(let authDataResult):
                    case .success(let authDataResult):

                    //TODO: create a database user
                        //create a database user only from  туц фгерутешсфеув фссщгте
                        self?.createDatabaseUser(authDataResult: authDataResult)
//                    DispatchQueue.main.async {
////                        self?.errorLabel.text = "Hope ypu enjoy our app experience. Email used: \(authDataResult.user.email ?? "")"
////                        self?.errorLabel.textColor = .systemGreen
//
//                        //TODO: navigate to the main view
//                        self?.navigateToMainView()
                    }
                }
            }
        }
    //create a database user 1
    private func createDatabaseUser(authDataResult: AuthDataResult) {
        databaseService.createDatabaseUser(authDataResult: authDataResult) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Account error", message: error.localizedDescription)
                }
            case .success:
                DispatchQueue.main.async {
                    self?.navigateToMainView()
                }
            }
        }
    }
    
    private func navigateToMainView() {
        UIViewController.showViewController(storyboardName: "MainView", viewControllerId: "MainTabBarController")
    }
    
    private func clearErrorLabel() {
        errorLabel.text = ""
    }
    
    @IBAction func toggleAccountState(_ sender: UIButton) {
        // change the account login state
        accountState = accountState == .existingUser ? .newUser : .existingUser
        
        // animation duration
        let duration: TimeInterval = 1.0
        
        if accountState == .existingUser {
            UIView.transition(with: containerView, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.loginButton.setTitle("Login", for: .normal)
                self.accountStateMessageLabel.text = "Don't have an account ? Click"
                self.accountStateButton.setTitle("SIGNUP", for: .normal)
            }, completion: nil)
        } else {
            UIView.transition(with: containerView, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.loginButton.setTitle("Sign Up", for: .normal)
                self.accountStateMessageLabel.text = "Already have an account ?"
                self.accountStateButton.setTitle("LOGIN", for: .normal)
            }, completion: nil)
        }
    }
    
}

