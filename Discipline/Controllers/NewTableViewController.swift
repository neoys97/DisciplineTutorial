//
//  NewTableViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 20/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class NewTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

}
