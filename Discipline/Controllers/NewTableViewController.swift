//
//  NewTableViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 20/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewTableViewController: UITableViewController {

    var rootTabBarController: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // code for retrieving goal
        if let student = rootTabBarController.student {
            if let goal = student.goal {
                print ("My goal is \(goal)")
            }
        }
    }
    
    @IBAction func changeGoal(_ sender: Any) {
        // code for changing goal
        let query = ["goal": "modified goals"]
        FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: query) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.present(Utilities.alertMessage(title: "Error", message: "Error updating"), animated: true, completion: nil)
                }
                print (error)
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

}
