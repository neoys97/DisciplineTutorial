//
//  BookListTableViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class BookListTableViewController: UITableViewController, ReloadableViewController {

    var rootTabBarController: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let bookList = rootTabBarController.currentClassBooks {
            if bookList.count == 0 {
                present(Utilities.alertMessage(title: "No books uploaded", message: "Your teachers have not updated the book list"), animated: true, completion: nil)
            }
        }
        else {
            present(Utilities.alertMessage(title: "No books uploaded", message: "Your teachers have not updated the book list"), animated: true, completion: nil)
        }
        reloadView()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        rootTabBarController.refresh()
    }
    
    func reloadView() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "viewBookDetailSegue") {
            let dest = segue.destination as! BookDetailViewController
            let bookID = rootTabBarController.currentClassBooksKeys![tableView.indexPathForSelectedRow!.row]
            dest.book = rootTabBarController.currentClassBooks![bookID]!
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            guard let bookList = rootTabBarController.currentClassBooks else { return 0 }
            return bookList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (100.0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookListDescriptionIdentifier", for: indexPath)
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookListCellIdentifier", for: indexPath) as! BookListTableViewCell
            guard let bookList = rootTabBarController.currentClassBooks else { return cell }
            let book = bookList[rootTabBarController.currentClassBooksKeys![indexPath.row]]!
            cell.bookNameLabel.text = book.name
            cell.bookIconView.tintColor = book.bought ? Colors.BdazzledBlue : Colors.BurntSienna
            cell.boughtControl.selectedSegmentIndex = book.bought ? 0 : 1
            cell.index = indexPath.row
            cell.bookIconView.backgroundColor = UIColor.clear
            cell.bookIconView.image = UIImage.init(systemName: "book")
            cell.delegate = self
            return cell
        }
        return (UITableViewCell())
    }
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let boughtAction = UIContextualAction(style: .normal, title: "Bought", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            tableView.isUserInteractionEnabled = false
//            var currentBooks = self.rootTabBarController.student!.books
//            let boughtBookID = self.rootTabBarController.currentClassBooksKeys![indexPath.row]
//            if currentBooks.contains(boughtBookID) {
//                tableView.isUserInteractionEnabled = true
//                success(true)
//                return
//            }
//            currentBooks.append(boughtBookID)
//            let updateQuery = ["books": currentBooks]
//            FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery) { (error) in
//                if let error = error {
//                    print (error)
//                    DispatchQueue.main.async {
//                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
//                    }
//                }
//                else {
//                    self.rootTabBarController.student!.books.append(boughtBookID)
//                    self.rootTabBarController.currentClassBooks![boughtBookID]!.bought = true
//                    tableView.reloadData()
//                }
//                tableView.isUserInteractionEnabled = true
//            }
//            success(true)
//        })
//        boughtAction.image = UIImage(systemName: "cart.badge.plus")
//        boughtAction.backgroundColor = .systemGreen
//
//        return UISwipeActionsConfiguration(actions: [boughtAction])
//    }
//
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let notBoughtAction = UIContextualAction(style: .normal, title: "Not bought", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            tableView.isUserInteractionEnabled = false
//            var currentBooks = self.rootTabBarController.student!.books
//            let boughtBookID = self.rootTabBarController.currentClassBooksKeys![indexPath.row]
//            let index = currentBooks.firstIndex(of: boughtBookID)
//            guard let validIndex = index else {
//                tableView.isUserInteractionEnabled = true
//                success(true)
//                return
//            }
//            currentBooks.remove(at: validIndex)
//            let updateQuery = ["books": currentBooks]
//            FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery) { (error) in
//                if let error = error {
//                    print (error)
//                    DispatchQueue.main.async {
//                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
//                    }
//                }
//                else {
//                    self.rootTabBarController.student!.books.remove(at: indexPath.row)
//                    self.rootTabBarController.currentClassBooks![boughtBookID]!.bought = false
//                    tableView.reloadData()
//                }
//                tableView.isUserInteractionEnabled = true
//            }
//            success(true)
//        })
//        notBoughtAction.image = UIImage(systemName: "cart.badge.minus")
//        notBoughtAction.backgroundColor = .systemRed
//
//        return UISwipeActionsConfiguration(actions: [notBoughtAction])
//    }
}

extension BookListTableViewController: BookListDelegate {
    func boughtBook(index: Int) {
        var currentBooks = self.rootTabBarController.student!.books
        let boughtBookID = self.rootTabBarController.currentClassBooksKeys![index]
        if currentBooks.contains(boughtBookID) {
            tableView.isUserInteractionEnabled = true
            return
        }
        currentBooks.append(boughtBookID)
        let updateQuery = ["books": currentBooks]
        FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery) { (error) in
            if let error = error {
                print (error)
                DispatchQueue.main.async {
                    self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                }
            }
            else {
                self.rootTabBarController.student!.books.append(boughtBookID)
                self.rootTabBarController.currentClassBooks![boughtBookID]!.bought = true
                self.tableView.reloadData()
            }
            self.tableView.isUserInteractionEnabled = true
        }
    }
    
    func notBoughtBook(index: Int) {
        var currentBooks = self.rootTabBarController.student!.books
        let boughtBookID = self.rootTabBarController.currentClassBooksKeys![index]
        let i = currentBooks.firstIndex(of: boughtBookID)
        guard let validIndex = i else {
            tableView.isUserInteractionEnabled = true
            return
        }
        currentBooks.remove(at: validIndex)
        let updateQuery = ["books": currentBooks]
        FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery) { (error) in
            if let error = error {
                print (error)
                DispatchQueue.main.async {
                    self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                }
            }
            else {
                self.rootTabBarController.student!.books.remove(at: index)
                self.rootTabBarController.currentClassBooks![boughtBookID]!.bought = false
                self.tableView.reloadData()
            }
            self.tableView.isUserInteractionEnabled = true
        }
    }
}
