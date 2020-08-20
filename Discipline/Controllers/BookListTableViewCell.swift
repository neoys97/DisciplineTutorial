//
//  BookListTableViewCell.swift
//  Discipline
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class BookListTableViewCell: UITableViewCell {

    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var bookIconView: UIImageView!
    @IBOutlet weak var boughtControl: UISegmentedControl!
    
    var index: Int?
    var delegate: BookListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func boughtControlChanged(_ sender: Any) {
        let currentSC = sender as! UISegmentedControl
        if let index = index, let delegate = delegate {
            if currentSC.selectedSegmentIndex == 0 {
                delegate.boughtBook(index: index)
            }
            else if currentSC.selectedSegmentIndex == 1 {
                delegate.notBoughtBook(index: index)
            }
        }
    }
}

protocol BookListDelegate {
    func boughtBook(index: Int)
    func notBoughtBook(index: Int)
}
