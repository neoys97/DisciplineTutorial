//
//  LoginViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signBtn: UIButton!
    @IBOutlet weak var switchModeBtn: UIButton!
    
    let emailKey = "EMAIL"
    let passwordKey = "PASSWORD"
    let defaults = UserDefaults.standard
    
    var existingUser = true {
        didSet {
            if existingUser {
                signBtn.setTitle("Sign In", for: .normal)
                switchModeBtn.setTitle("New User", for: .normal)
                UIView.transition(with: self.view, duration: 2.0, options: .curveEaseIn, animations: {
                    self.view.backgroundColor = .white
                })
            }
            else {
                signBtn.setTitle("Create User", for: .normal)
                switchModeBtn.setTitle("Existing User", for: .normal)
                UIView.transition(with: self.view, duration: 2.0, options: .curveEaseIn, animations: {
                    self.view.backgroundColor = .gray
                })
            }
        }
    }
    var loadingIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        view.addSubview(self.loadingIndicatorView.getViewActivityIndicator())
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if let email = defaults.string(forKey: emailKey), let password = defaults.string(forKey: passwordKey) {
            emailTF.text = email
            passwordTF.text = password
            view.isUserInteractionEnabled = false
            loadingIndicatorView.startAnimating()
            logInUser(email: email, password: password)
        }
    }

    @IBAction func signBtnPressed(_ sender: Any) {
        if let email = emailTF.text, let password = passwordTF.text, email != "", password != "" {
            if Utilities.isValidEmail(email) {
                view.isUserInteractionEnabled = false
                loadingIndicatorView.startAnimating()
                if existingUser {
                    logInUser(email: email, password: password)
                }
                else {
                    createUser(email: email, password: password)
                }
            }
            else {
                present(Utilities.alertMessage(title: "Invalid Email", message: "Email format is not valid!"), animated: true)
            }
        }
        else {
            present(Utilities.alertMessage(title: "Error", message: "Email or Password cannot be empty"), animated: true)
        }
        
    }
    
    @IBAction func switchModeBtnPressed(_ sender: Any) {
        existingUser = !existingUser
    }
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Error", message: "Error occured at server side"), animated: true)
                        }
                    case .emailAlreadyInUse:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Email in use", message: "The Email has already been registered"), animated: true)
                        }
                    case .invalidEmail:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Invalid Email", message: "Email format is not valid!"), animated: true)
                        }
                    case .weakPassword:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Password is too short", message: "Password should consist of at least 6 characters!"), animated: true)
                        }
                    default:
                        print("Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Error", message: "Unknown error"), animated: true)
                        }
                }
            }
            else {
                print("User signs up successfully")
                self.defaults.setValue(email, forKey: self.emailKey)
                self.defaults.setValue(password, forKey: self.passwordKey)
                let newUserInfo = Auth.auth().currentUser
                do {
                    try FirebaseUtil.newUser(uniqueID: newUserInfo!.uid, name: newUserInfo!.email!) { student, err in
                        DispatchQueue.main.async {
                            if let _ = err {
                                self.loadingIndicatorView.stopAnimating()
                                self.present(Utilities.alertMessage(title: "Error", message: "Failed to create user on Firestore"), animated: true)
                                self.view.isUserInteractionEnabled = true
                            }
                            else {
                                self.loadingIndicatorView.stopAnimating()
                                self.view.isUserInteractionEnabled = true
                                self.loggedIn()
                            }
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        self.loadingIndicatorView.stopAnimating()
                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to create user on Firestore"), animated: true)
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
            self.loadingIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func logInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Error", message: "Error occured at server side"), animated: true)
                        }
                    case .userDisabled:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "User Error", message: "User disabled"), animated: true)
                        }
                    case .wrongPassword:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Wrong Password", message: "Please provide the correct password"), animated: true)
                        }
                    case .invalidEmail:
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Invalid Email", message: "Email is not registered"), animated: true)
                        }
                    default:
                        print("Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.present(Utilities.alertMessage(title: "Error", message: "Unknown error"), animated: true)
                        }
                }
            }
            else {
                print("User signs in successfully")
                self.defaults.setValue(email, forKey: self.emailKey)
                self.defaults.setValue(password, forKey: self.passwordKey)
                self.loggedIn()
            }
            DispatchQueue.main.async {
                self.loadingIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func loggedIn() {
        let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "MainMenu")
        UIApplication.shared.windows.first?.rootViewController = targetVC!
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
