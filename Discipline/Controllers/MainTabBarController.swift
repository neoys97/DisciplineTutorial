//
//  MainTabBarController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    var student: Student?
    var classGroupKeys: [String]?
    var classGroup: [String: ClassGroup]?
    var currentClassBooksKeys: [String]?
    var currentClassBooks: [String: Book]?
    
    let authUserInfo = Auth.auth().currentUser
    var loadingIndicatorView: ActivityIndicatorView!
    
    var usersLoading = false
    var classLoading = false
    var booksLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorView = ActivityIndicatorView(title: "Fetching data...", center: self.view.center)
        view.addSubview(self.loadingIndicatorView.getViewActivityIndicator())
        refresh()
    }
    
    func refresh() {
        clearData()
        retrieveAllClassGroups()
        retriveUser()
    }
    
    func retriveUser() {
        usersLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getUser(uniqueID: authUserInfo!.uid) {[unowned self] student, error in
            if let student = student {
                self.student = student
                if let classGroupID = student.classGroupID {
                    self.retrieveBooks(classGroupID: classGroupID)
                }
            }
            else {
                if let error = error {
                    self.loadDataErrorAlert(error: error)
                }
                else {
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Server error", message: "User data is missing in the server, please contact the admin"), animated: true)
                    }
                }
            }
            self.usersLoading = false
            self.reloadCurrentViewController()
        }
    }
    
    func retrieveAllClassGroups() {
        classLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getAllClassGroups { [unowned self] (retrievedData, error) in
            if let error = error {
                self.loadDataErrorAlert(error: error)
            }
            else if let classes = retrievedData{
                self.classGroup = classes
                self.classGroupKeys = [String](classes.keys).sorted()
            }
            self.classLoading = false
            self.reloadCurrentViewController()
        }
    }
    
    func retrieveBooks(classGroupID: String) {
        booksLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getBooks(classGroupID: classGroupID) {[unowned self] (books, error) in
            if let error = error {
                self.loadDataErrorAlert(error: error)
            }
            else if let books = books {
                self.currentClassBooks = books
                self.currentClassBooksKeys = [String](books.keys).sorted()
                if let boughtBooksID = self.student?.books {
                    for (id, _) in self.currentClassBooks! {
                        if boughtBooksID.contains(id) {
                            self.currentClassBooks![id]!.bought = true
                        }
                    }
                }
            }
            self.classLoading = false
            self.reloadCurrentViewController()
        }
    }
    
    func reloadCurrentViewController() {
        guard checkLoading() else { return }
        if let currentViewController = selectedViewController as? ReloadableViewController {
            currentViewController.reloadView()
        }
        else if let currentNavController = selectedViewController as? UINavigationController {
            if let currentViewController = currentNavController.topViewController as? ReloadableViewController {
                currentViewController.reloadView()
            }
        }
        view.isUserInteractionEnabled = true
        loadingIndicatorView.stopAnimating()
    }
    
    func checkLoading() -> Bool {
        if usersLoading || classLoading || booksLoading {
            return true
        }
        return false
    }
    
    func clearData() {
        self.student = nil
        self.classGroupKeys = nil
        self.classGroup = nil
        self.currentClassBooksKeys = nil
        self.currentClassBooks = nil
    }
    
    func loadDataErrorAlert(error: Error?) {
        DispatchQueue.main.async {
            self.present(Utilities.alertMessage(title: "Data error", message: "Failed to retrive data"), animated: true)
        }
        print(error)
    }
}

protocol ReloadableViewController {
    func reloadView()
}
